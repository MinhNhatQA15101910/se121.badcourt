using AutoMapper;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using MongoDB.Bson;
using RealtimeService.Application.Interfaces;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Enums;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class MessageHub(
    IMessageRepository messageRepository,
    IGroupRepository groupRepository,
    IConnectionRepository connectionRepository,
    IFileService fileService,
    IMapper mapper
) : Hub
{
    public override async Task OnConnectedAsync()
    {
        // Get the user ID from the context
        var httpContext = Context.GetHttpContext();
        var otherUser = httpContext?.Request.Query["user"];

        // If the user is not authenticated or the other user is not specified, throw an exception
        if (Context.User == null || string.IsNullOrEmpty(otherUser))
        {
            throw new HubException("Cannot join group");
        }

        var groupName = GetGroupName(Context.User.GetUserId().ToString(), otherUser);
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

        var group = await groupRepository.GetGroupByNameAsync(groupName);
        if (group == null)
        {
            group = new Group
            {
                Name = groupName,
                UserIds = [Context.User.GetUserId().ToString(), otherUser],
            };
            await groupRepository.AddGroupAsync(group);
        }

        var connection = new Connection
        {
            ConnectionId = Context.ConnectionId,
            GroupId = group.Id,
            UserId = Context.User.GetUserId().ToString()
        };
        await connectionRepository.AddConnectionAsync(connection);

        var groupDto = mapper.Map<GroupDto>(group);
        groupDto.Connections.Add(mapper.Map<ConnectionDto>(connection));

        await Clients.Group(groupName).SendAsync("UpdatedGroup", groupDto);

        var messages = await messageRepository.GetMessagesAsync(
            Context.User.GetUserId().ToString(),
            new MessageParams
            {
                GroupId = group.Id,
                PageNumber = 1,
                PageSize = 20,
            });

        var pagedMessages = new PagedResult<MessageDto>
        {
            CurrentPage = messages.CurrentPage,
            TotalPages = messages.TotalPages,
            PageSize = messages.PageSize,
            TotalCount = messages.TotalCount,
            Items = messages
        };

        await Clients.Caller.SendAsync("ReceiveMessageThread", pagedMessages);
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var connection = await connectionRepository.GetConnectionByIdAsync(Context.ConnectionId)
            ?? throw new HubException("Connection not found");
        var group = await groupRepository.GetGroupForConnectionAsync(Context.ConnectionId)
            ?? throw new HubException("Group not found for connection");

        if (connection != null && group != null)
        {
            await connectionRepository.DeleteConnectionAsync(connection.ConnectionId);

            var groupDto = mapper.Map<GroupDto>(group);
            groupDto.Connections.RemoveAll(c => c.ConnectionId == Context.ConnectionId);

            // Notify other clients in the group about the updated group
            await Clients.Group(group.Name).SendAsync("UpdatedGroup", groupDto);
        }

        await base.OnDisconnectedAsync(exception);
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
