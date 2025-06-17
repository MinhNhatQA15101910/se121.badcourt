using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class NotificationHub(
    NotificationHubTracker notificationHubTracker,
    INotificationRepository notificationRepository
) : Hub
{
    public override async Task OnConnectedAsync()
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        await notificationHubTracker.UserConnectedAsync(Context.User.GetUserId().ToString(), Context.ConnectionId);

        var notificationDtos = await notificationRepository.GetNotificationsAsync(
            Context.User.GetUserId().ToString(),
            new NotificationParams
            {
                PageSize = 20,
                PageNumber = 1
            });

        var pagedNotificationDtos = new PagedResult<NotificationDto>
        {
            CurrentPage = notificationDtos.CurrentPage,
            TotalPages = notificationDtos.TotalPages,
            PageSize = notificationDtos.PageSize,
            TotalCount = notificationDtos.TotalCount,
            Items = notificationDtos
        };

        await Clients.Caller.SendAsync("ReceiveNotifications", pagedNotificationDtos);
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        await notificationHubTracker.UserDisconnectedAsync(Context.User.GetUserId().ToString(), Context.ConnectionId);

        await base.OnDisconnectedAsync(exception);
    }
}
