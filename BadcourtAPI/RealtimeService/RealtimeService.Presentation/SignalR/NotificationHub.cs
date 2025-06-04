using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class NotificationHub(
    INotificationRepository notificationRepository
) : Hub
{
    public override async Task OnConnectedAsync()
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        var notificationDtos = await notificationRepository.GetNotificationsAsync(new NotificationParams
        {
            UserId = Context.User.GetUserId().ToString(),
            PageSize = 20,
            PageNumber = 1
        });

        await Clients.Caller.SendAsync("ReceiveNotifications", notificationDtos);
    }
}
