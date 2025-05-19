using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Presentation.Extensions;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class PresenceHub(PresenceTracker presenceTracker) : Hub
{
    public override async Task OnConnectedAsync()
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        await presenceTracker.UserConnected(Context.User.GetUserId().ToString(), Context.ConnectionId);
        await Clients.Others.SendAsync("UserIsOnline", Context.User.GetUserId());

        var onlineUsers = await presenceTracker.GetOnlineUsers();
        await Clients.All.SendAsync("GetOnlineUsers", onlineUsers);
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        await presenceTracker.UserDisconnected(Context.User.GetUserId().ToString(), Context.ConnectionId);
        await Clients.Others.SendAsync("UserIsOffline", Context.User?.GetUserId());

        var onlineUsers = await presenceTracker.GetOnlineUsers();
        await Clients.All.SendAsync("GetOnlineUsers", onlineUsers);

        await base.OnDisconnectedAsync(exception);
    }
}
