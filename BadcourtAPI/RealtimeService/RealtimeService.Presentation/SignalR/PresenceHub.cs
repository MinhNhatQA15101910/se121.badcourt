using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Presentation.Extensions;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class PresenceHub(PresenceHubTracker presenceHubTracker) : Hub
{
    public override async Task OnConnectedAsync()
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        var isOnline = await presenceHubTracker.UserConnectedAsync(Context.User.GetUserId().ToString(), Context.ConnectionId);
        if (isOnline) await Clients.Others.SendAsync("UserIsOnline", Context.User.GetUserId());

        var onlineUsers = await presenceHubTracker.GetOnlineUsersAsync();
        await Clients.Caller.SendAsync("GetOnlineUsers", onlineUsers);
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        var isOffline = await presenceHubTracker.UserDisconnectedAsync(Context.User.GetUserId().ToString(), Context.ConnectionId);
        if (isOffline) await Clients.Others.SendAsync("UserIsOffline", Context.User?.GetUserId());

        await base.OnDisconnectedAsync(exception);
    }
}
