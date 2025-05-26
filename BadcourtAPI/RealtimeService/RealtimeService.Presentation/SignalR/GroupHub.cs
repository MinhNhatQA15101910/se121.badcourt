using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;

namespace RealtimeService.Presentation.SignalR;

public class GroupHub(IGroupRepository groupRepository) : Hub
{
    public override async Task OnConnectedAsync()
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        var userId = Context.User.GetUserId().ToString();

        var groups = await groupRepository.GetGroupsForUserAsync(userId);
        await Clients.Caller.SendAsync("ReceiveGroups", groups);
    }
}
