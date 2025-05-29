using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Presentation.Extensions;

namespace RealtimeService.Presentation.SignalR;

/// <summary>
/// This hub will be connected when user is logged in and disconnected when user is logged out.
/// </summary>
/// <param name="presenceTracker"></param>
[Authorize]
public class PresenceHub(PresenceTracker presenceTracker) : Hub
{
    public override async Task OnConnectedAsync()
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        var isOnline = await presenceTracker.UserConnected(Context.User.GetUserId().ToString(), Context.ConnectionId);
        if (isOnline) await Clients.Others.SendAsync("UserIsOnline", Context.User.GetUserId());

        var onlineUsers = await presenceTracker.GetOnlineUsers();
        await Clients.Caller.SendAsync("GetOnlineUsers", onlineUsers);
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        var isOffline = await presenceTracker.UserDisconnected(Context.User.GetUserId().ToString(), Context.ConnectionId);
        if (isOffline) await Clients.Others.SendAsync("UserIsOffline", Context.User?.GetUserId());

        await base.OnDisconnectedAsync(exception);
    }
}
