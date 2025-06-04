using RealtimeService.Domain.Entities;

namespace RealtimeService.Domain.Interfaces;

public interface INotificationRepository
{
    Task<List<Notification>> GetNotificationsForUserAsync(string userId, CancellationToken cancellationToken = default);
}
