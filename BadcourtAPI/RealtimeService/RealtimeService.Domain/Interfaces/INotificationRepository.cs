using RealtimeService.Domain.Entities;

namespace RealtimeService.Domain.Interfaces;

public interface INotificationRepository
{
    Task<List<Notification>> GetNotificationsAsync(string userId, CancellationToken cancellationToken = default);
}
