using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;
using SharedKernel.DTOs;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class NotificationHub(
    INotificationRepository notificationRepository,
    IMapper mapper
) : Hub
{
    public override async Task OnConnectedAsync()
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        var userId = Context.User.GetUserId().ToString();

        var notifications = await notificationRepository.GetNotificationsForUserAsync(userId);

        var notificationDtos = notifications.Select(mapper.Map<NotificationDto>).ToList();

        await Clients.Caller.SendAsync("ReceiveNotifications", notificationDtos);
    }
}
