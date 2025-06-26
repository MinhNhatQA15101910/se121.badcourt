using AutoMapper;
using CloudinaryDotNet.Actions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using MongoDB.Bson;
using RealtimeService.Application.ApiRepositories;
using RealtimeService.Application.Interfaces;
using RealtimeService.Application.Queries.GetMessages;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Enums;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.DTOs;
using RealtimeService.Presentation.Extensions;
using RealtimeService.Presentation.SignalR;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;
using SharedKernel.Params;

namespace RealtimeService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class MessagesController(
    IMediator mediator,
    IUserApiRepository userApiRepository,
    IGroupRepository groupRepository,
    IMessageRepository messageRepository,
    IConnectionRepository connectionRepository,
    GroupHubTracker groupHubTracker,
    IMapper mapper,
    IHubContext<GroupHub> groupHub,
    IHubContext<MessageHub> messageHub,
    IFileService fileService
) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<PagedResult<MessageDto>>> GetMessages([FromQuery] MessageParams messageParams)
    {
        return await mediator.Send(new GetMessagesQuery(messageParams));
    }

    [HttpPost]
    public async Task<ActionResult<MessageDto>> SendMessage(CreateMessageDto createMessageDto)
    {
        var userId = User.GetUserId();

        if (userId.ToString() == createMessageDto.RecipientId)
        {
            throw new BadRequestException("You cannot send messages to yourself");
        }

        var sender = await userApiRepository.GetUserByIdAsync(userId);
        var recipient = await userApiRepository.GetUserByIdAsync(Guid.Parse(createMessageDto.RecipientId));
        if (sender == null || recipient == null)
        {
            throw new BadRequestException("Cannot send message");
        }

        // Check if the message has content or resources
        if (string.IsNullOrWhiteSpace(createMessageDto.Content) && createMessageDto.Resources.Count == 0)
        {
            throw new BadRequestException("Message must have content or resources");
        }

        var groupName = GetGroupName(sender.Id.ToString(), recipient.Id.ToString());
        var group = await groupRepository.GetGroupByNameAsync(groupName);
        if (group == null)
        {
            group = new Group
            {
                Id = ObjectId.GenerateNewId().ToString(),
                Name = groupName,
                UserIds = [sender.Id.ToString(), recipient.Id.ToString()],
                Usernames = [sender.Username, recipient.Username],
                HasMessage = false,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            await groupRepository.AddGroupAsync(group);
        }

        var messageId = ObjectId.GenerateNewId().ToString();
        var isMain = true;
        var files = new List<Domain.Entities.File>();
        foreach (var resource in createMessageDto.Resources)
        {
            var file = await UploadFileAsync(messageId, resource, isMain);
            files.Add(file);

            isMain = false;
        }

        var senderImageUrl = sender.Photos.FirstOrDefault(x => x.IsMain)?.Url ?? string.Empty;
        var message = new Message
        {
            Id = ObjectId.GenerateNewId().ToString(),
            SenderId = sender.Id.ToString(),
            SenderUsername = sender.Username,
            SenderImageUrl = senderImageUrl ?? string.Empty,
            ReceiverId = recipient.Id.ToString(),
            GroupId = group.Id,
            Content = createMessageDto.Content,
            Resources = files,
        };
        await messageRepository.AddMessageAsync(message);

        var groupConnections = await connectionRepository.GetConnectionsByGroupIdAsync(group.Id);
        if (groupConnections.Any(x => x.UserId == recipient.Id.ToString()))
        {
            message.DateRead = DateTime.UtcNow;
            await messageRepository.UpdateMessageAsync(message);
        }
        else
        {
            var userConnections = await groupHubTracker.GetConnectionsForUserAsync(recipient.Id.ToString());
            if (userConnections != null && userConnections?.Count != null)
            {
                var groupDto = mapper.Map<GroupDto>(group);
                groupDto.Connections = [.. groupConnections.Select(mapper.Map<ConnectionDto>)];

                var users = await Task.WhenAll(group.UserIds.Select(id => userApiRepository.GetUserByIdAsync(Guid.Parse(id))));
                groupDto.Users = [.. users.Where(u => u != null).Select(mapper.Map<UserDto>)];

                groupDto.LastMessage = mapper.Map<MessageDto>(message);
                groupDto.UpdatedAt = DateTime.UtcNow;

                await groupHub.Clients.Clients(userConnections).SendAsync("NewMessageReceived", groupDto);
            }
        }

        if (!group.HasMessage) group.HasMessage = true;
        group.UpdatedAt = DateTime.UtcNow;
        await groupRepository.UpdateGroupAsync(group);

        var messageDto = mapper.Map<MessageDto>(message);
        await messageHub.Clients.Group(groupName).SendAsync("NewMessage", mapper.Map<MessageDto>(messageDto));

        return messageDto;
    }

    private static string GetGroupName(string caller, string? other)
    {
        var stringCompare = string.CompareOrdinal(caller, other) < 0;
        return stringCompare ? $"{caller}-{other}" : $"{other}-{caller}";
    }

    private static FileType GetFileType(IFormFile file)
    {
        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        return extension switch
        {
            ".jpg" or ".jpeg" or ".png" or ".gif" => FileType.Image,
            ".mp4" or ".avi" or ".mov" => FileType.Video,
            _ => FileType.Unknown
        };
    }

    private async Task<Domain.Entities.File> UploadFileAsync(string messageId, IFormFile file, bool isMain)
    {
        UploadResult uploadResult;

        if (file.Length == 0)
            throw new HubException("File is empty");

        var fileType = GetFileType(file);

        if (fileType == FileType.Image)
            uploadResult = await fileService.UploadPhotoAsync($"messages/{messageId}", file);
        else if (fileType == FileType.Video)
            uploadResult = await fileService.UploadVideoAsync($"messages/{messageId}", file);
        else
            throw new HubException("Unsupported file type");

        if (uploadResult.Error != null)
            throw new HubException(uploadResult.Error.Message);

        return new Domain.Entities.File
        {
            Id = ObjectId.GenerateNewId().ToString(),
            Url = uploadResult.SecureUrl.AbsoluteUri,
            PublicId = uploadResult.PublicId,
            IsMain = isMain,
            FileType = fileType
        };
    }
}
