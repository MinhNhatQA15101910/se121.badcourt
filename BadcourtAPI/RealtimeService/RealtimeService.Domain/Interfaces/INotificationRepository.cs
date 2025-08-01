using RealtimeService.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Domain.Interfaces;

public interface INotificationRepository
{
    Task AddNotificationAsync(Notification notification, CancellationToken cancellationToken = default);
    Task<Notification?> GetNotificationByIdAsync(
        string notificationId, CancellationToken cancellationToken = default);
    Task<PagedList<NotificationDto>> GetNotificationsAsync(
        string userId, NotificationParams notificationParams, CancellationToken cancellationToken = default);
    Task<int> GetNumberOfUnreadNotificationsAsync(
        string userId, CancellationToken cancellationToken = default);
    Task<IEnumerable<Notification>> GetUnreadNotificationsAsync(string userId, CancellationToken cancellationToken = default);
    Task UpdateNotificationAsync(Notification notification, CancellationToken cancellationToken = default);
}
