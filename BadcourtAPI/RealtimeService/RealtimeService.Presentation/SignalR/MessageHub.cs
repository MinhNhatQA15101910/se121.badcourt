using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;

namespace RealtimeService.Presentation.SignalR;

public class MessageHub(IMessageRepository messageRepository) : Hub
{
    public override async Task OnConnectedAsync()
    {
        var httpContext = Context.GetHttpContext();
        var otherUser = httpContext?.Request.Query["user"];

        if (Context.User == null || string.IsNullOrEmpty(otherUser))
        {
            throw new HubException("Cannot join group");
        }

        var groupName = GetGroupName(Context.User.GetUserId().ToString(), otherUser);
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

        var messages = await messageRepository.GetMessageThreadAsync(
            Context.User.GetUserId().ToString(),
            otherUser!
        );
        await Clients.Group(groupName).SendAsync("ReceiveMessages", messages);
    }

    public override Task OnDisconnectedAsync(Exception? exception)
    {
        return base.OnDisconnectedAsync(exception);
    }

    private string GetGroupName(string caller, string? other)
    {
        var stringCompare = string.CompareOrdinal(caller, other) < 0;
        return stringCompare ? $"{caller}-{other}" : $"{other}-{caller}";
    }
}
