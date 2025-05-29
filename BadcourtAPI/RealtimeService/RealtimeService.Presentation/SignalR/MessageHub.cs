using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.ApiRepositories;
using RealtimeService.Presentation.DTOs;
using RealtimeService.Presentation.Extensions;
using SharedKernel.DTOs;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class MessageHub(
    IMessageRepository messageRepository,
    IGroupRepository groupRepository,
    IConnectionRepository connectionRepository,
    IUserApiRepository userApiRepository,
    IHubContext<GroupHub> groupHub,
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

        await Clients.Group(groupName).SendAsync("UpdatedGroup", group);

        var messages = await messageRepository.GetMessagesByGroupIdAsync(
            Context.User.GetUserId().ToString(), group.Id);
        await Clients.Caller.SendAsync("ReceiveMessageThread", messages.Select(mapper.Map<MessageDto>).ToList());
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

        var groupName = GetGroupName(sender.Id.ToString(), recipient.Id.ToString());
        var group = await groupRepository.GetGroupByNameAsync(groupName)
            ?? throw new HubException("Group not found");

        var message = new Message
        {
            SenderId = sender.Id.ToString(),
            SenderUsername = sender.Username,
            SenderImageUrl = sender.PhotoUrl ?? string.Empty,
            GroupId = group.Id,
            Content = createMessageDto.Content,
        };
        await messageRepository.AddMessageAsync(message);

        var groupConnections = await connectionRepository.GetConnectionsByGroupIdAsync(group.Id);
        if (groupConnections.Any(x => x.UserId == recipient.Id.ToString()))
        {
            message.DateRead = DateTime.UtcNow;
        }
        else
        {
            var userConnections = await PresenceTracker.GetConnectionsForUser(recipient.Id.ToString());
            if (userConnections != null && userConnections?.Count != null)
            {
                var groupDto = mapper.Map<GroupDto>(group);
                groupDto.Connections = [.. groupConnections.Select(mapper.Map<ConnectionDto>)];
                foreach (var userIdInGroup in group.UserIds)
                {
                    var userDto = await userApiRepository.GetUserByIdAsync(Guid.Parse(userIdInGroup))
                        ?? throw new HubException($"User with ID {userId} not found");
                    groupDto.Users.Add(userDto);
                }
                groupDto.LastMessage = mapper.Map<MessageDto>(message);
                groupDto.UpdatedAt = DateTime.UtcNow;

                await groupHub.Clients.Clients(userConnections).SendAsync("NewMessageReceived", groupDto);
            }
        }

        group.UpdatedAt = DateTime.UtcNow;
        await groupRepository.UpdateGroupAsync(group);

        await Clients.Group(groupName).SendAsync("NewMessage", mapper.Map<MessageDto>(message));
    }

    private static string GetGroupName(string caller, string? other)
    {
        var stringCompare = string.CompareOrdinal(caller, other) < 0;
        return stringCompare ? $"{caller}-{other}" : $"{other}-{caller}";
    }
}
