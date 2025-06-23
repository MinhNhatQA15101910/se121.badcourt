using Microsoft.AspNetCore.Http;
using RealtimeService.Application.Extensions;
using RealtimeService.Domain.Interfaces;

namespace RealtimeService.Application.Commands.ReadAllNotification;

public class ReadAllNotificationHandler(
    IHttpContextAccessor httpContextAccessor,
    INotificationRepository notificationRepository
) : ICommandHandler<ReadAllNotificationCommand, bool>
{
    public async Task<bool> Handle(ReadAllNotificationCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext?.User?.GetUserId();
        if (string.IsNullOrEmpty(userId))
            return false;

        var notifications = await notificationRepository.GetUnreadNotificationsAsync(userId, cancellationToken);
        if (notifications == null || !notifications.Any())
            return true;

        var tasks = notifications
            .Select(n =>
            {
                n.IsRead = true;
                return notificationRepository.UpdateNotificationAsync(n, cancellationToken);
            });

        await Task.WhenAll(tasks);

        return true;
    }
}
