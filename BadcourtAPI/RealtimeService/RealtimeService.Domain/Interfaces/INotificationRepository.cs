using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Domain.Interfaces;

public interface INotificationRepository
{
    Task<PagedList<NotificationDto>> GetNotificationsAsync(
        string userId, NotificationParams notificationParams, CancellationToken cancellationToken = default);
}
