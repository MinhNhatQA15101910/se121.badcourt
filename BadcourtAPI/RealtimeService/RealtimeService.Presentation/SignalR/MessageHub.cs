using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.ApiRepositories;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class MessageHub(
    IMessageRepository messageRepository,
    IGroupRepository groupRepository,
    IConnectionRepository connectionRepository,
    IUserApiRepository userApiRepository,
    IMapper mapper,
    IHubContext<PresenceHub> presenceHub
) : Hub
{
    // public override async Task OnConnectedAsync()
    // {
    //     var httpContext = Context.GetHttpContext();
    //     var otherUser = httpContext?.Request.Query["user"];

    //     if (Context.User == null || string.IsNullOrEmpty(otherUser))
    //     {
    //         throw new HubException("Cannot join group");
    //     }

    //     var groupName = GetGroupName(Context.User.GetUserId().ToString(), otherUser);
    //     await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
    //     var group = await AddToGroupAsync(groupName);
    //     await Clients.Group(groupName).SendAsync("UpdatedGroup", group);

    //     var messages = await messageRepository.GetMessageThreadAsync(
    //         Context.User.GetUserId().ToString(),
    //         otherUser!
    //     );
    //     await Clients.Caller.SendAsync("ReceiveMessageThread", messages);
    // }

    // public override async Task OnDisconnectedAsync(Exception? exception)
    // {
    //     var group = await RemoveFromGroupAsync();
    //     await Clients.Group(group.Name).SendAsync("UpdatedGroup", group);
    //     await base.OnDisconnectedAsync(exception);
    // }

    // public async Task SendMessage(CreateMessageDto createMessageDto)
    // {
    //     var userId = Context.User?.GetUserId() ?? throw new Exception("Could not get user");

    //     if (userId.ToString() == createMessageDto.RecipientId)
    //     {
    //         throw new HubException("You cannot send messages to yourself");
    //     }

    //     var sender = await userApiRepository.GetUserByIdAsync(userId);
    //     var recipient = await userApiRepository.GetUserByIdAsync(Guid.Parse(createMessageDto.RecipientId));
    //     if (sender == null || recipient == null)
    //     {
    //         throw new HubException("Cannot send message");
    //     }

    //     var message = new Message
    //     {
    //         SenderId = sender.Id.ToString(),
    //         SenderUsername = sender.Username,
    //         SenderImageUrl = sender.PhotoUrl ?? string.Empty,
    //         RecipientId = recipient.Id.ToString(),
    //         RecipientUsername = recipient.Username,
    //         RecipientImageUrl = recipient.PhotoUrl ?? string.Empty,
    //         Content = createMessageDto.Content,
    //     };

    //     var groupName = GetGroupName(sender.Id.ToString(), recipient.Id.ToString());
    //     var group = await groupRepository.GetGroupByNameAsync(groupName);

    //     if (group != null && group.Connections.Any(x => x.UserId == recipient.Id.ToString()))
    //     {
    //         message.DateRead = DateTime.UtcNow;
    //     }
    //     else
    //     {
    //         var connections = await PresenceTracker.GetConnectionsForUser(recipient.Id.ToString());
    //         if (connections != null && connections?.Count != null)
    //         {
    //             await presenceHub.Clients.Clients(connections).SendAsync("NewMessageReceived", new
    //             {
    //                 userId = sender.Id.ToString(),
    //             });
    //         }
    //     }

    //     await messageRepository.AddMessageAsync(message);

    //     await Clients.Group(groupName).SendAsync("NewMessage", mapper.Map<MessageDto>(message));
    // }

    // private async Task<Group> AddToGroupAsync(string groupName)
    // {
    //     var userId = Context.User?.GetUserId() ?? throw new Exception("Could not get user");
    //     var group = await groupRepository.GetGroupByNameAsync(groupName);

    //     var connection = new Connection
    //     {
    //         ConnectionId = Context.ConnectionId,
    //         UserId = userId.ToString()
    //     };
    //     await connectionRepository.AddConnectionAsync(connection);

    //     if (group == null)
    //     {
    //         group = new Group
    //         {
    //             Name = groupName,
    //         };
    //         await groupRepository.AddGroupAsync(group);
    //     }
    //     group.Connections.Add(connection);

    //     await groupRepository.UpdateGroupAsync(group);

    //     return group;
    // }

    // private async Task<Group> RemoveFromGroupAsync()
    // {
    //     var group = await groupRepository.GetGroupForConnectionAsync(Context.ConnectionId);
    //     var connection = group?.Connections.FirstOrDefault(x => x.ConnectionId == Context.ConnectionId);
    //     if (connection != null && group != null)
    //     {
    //         await connectionRepository.DeleteConnectionAsync(connection.ConnectionId);

    //         group.Connections.Remove(connection);
    //         await groupRepository.UpdateGroupAsync(group);

    //         return group;
    //     }

    //     throw new HubException("Group not found");
    // }

    // private static string GetGroupName(string caller, string? other)
    // {
    //     var stringCompare = string.CompareOrdinal(caller, other) < 0;
    //     return stringCompare ? $"{caller}-{other}" : $"{other}-{caller}";
    // }
}
