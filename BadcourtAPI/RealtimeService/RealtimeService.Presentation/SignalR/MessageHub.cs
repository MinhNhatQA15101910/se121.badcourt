using AutoMapper;
using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using MongoDB.Bson;
using RealtimeService.Application.ApiRepositories;
using RealtimeService.Application.Interfaces;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Enums;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.DTOs;
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
    IUserApiRepository userApiRepository,
    IFileService fileService,
    IHubContext<GroupHub> groupHub,
    GroupHubTracker groupHubTracker,
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

    public async Task SendMessage(CreateMessageDto createMessageDto)
    {
        var userId = Context.User?.GetUserId() ?? throw new Exception("Could not get user");

        if (userId.ToString() == createMessageDto.RecipientId)
        {
            throw new HubException("You cannot send messages to yourself");
        }

        var sender = await userApiRepository.GetUserByIdAsync(userId);
        var recipient = await userApiRepository.GetUserByIdAsync(Guid.Parse(createMessageDto.RecipientId));
        if (sender == null || recipient == null)
        {
            throw new HubException("Cannot send message");
        }

        // Check if the message has content or resources
        if (string.IsNullOrWhiteSpace(createMessageDto.Content) && createMessageDto.Base64Resources.Count == 0)
        {
            throw new HubException("Message must have content or resources");
        }

        var groupName = GetGroupName(sender.Id.ToString(), recipient.Id.ToString());
        var group = await groupRepository.GetGroupByNameAsync(groupName)
            ?? throw new HubException("Group not found");

        var messageId = ObjectId.GenerateNewId().ToString();
        var isMain = true;
        var files = new List<Domain.Entities.File>();
        foreach (var resource in createMessageDto.Base64Resources)
        {
            if (!resource.Contains(','))
                throw new HubException("Invalid base64 resource format");

            var fileType = GetFileType(resource);
            
            var file = await UploadFileAsync(messageId, resource, fileType, isMain);
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

        await Clients.Group(groupName).SendAsync("NewMessage", mapper.Map<MessageDto>(message));
    }

    private static string GetGroupName(string caller, string? other)
    {
        var stringCompare = string.CompareOrdinal(caller, other) < 0;
        return stringCompare ? $"{caller}-{other}" : $"{other}-{caller}";
    }

    private static FileType GetFileType(string base64)
    {
        var mimeType = GetMimeTypeFromBase64(base64);

        if (mimeType.StartsWith("image/")) return FileType.Image;
        if (mimeType.StartsWith("video/")) return FileType.Video;

        return FileType.Unknown;
    }

    private static string GetMimeTypeFromBase64(string base64String)
    {
        var dataHeader = base64String[..base64String.IndexOf(',')];
        return dataHeader.Split(':')[1].Split(';')[0];
    }

    private async Task<Domain.Entities.File> UploadFileAsync(string messageId, string base64, FileType type, bool isMain)
    {
        UploadResult uploadResult;

        if (type == FileType.Image)
            uploadResult = await fileService.UploadPhotoAsync($"messages/{messageId}", base64);
        else if (type == FileType.Video)
            uploadResult = await fileService.UploadVideoAsync($"messages/{messageId}", base64);
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
            FileType = type
        };
    }
}
