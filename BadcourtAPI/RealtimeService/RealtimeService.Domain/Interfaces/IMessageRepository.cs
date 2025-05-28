using RealtimeService.Domain.Entities;
using SharedKernel.DTOs;

namespace RealtimeService.Domain.Interfaces;

public interface IMessageRepository
{
    Task AddMessageAsync(
        Message message, CancellationToken cancellationToken = default);
    Task<Message?> GetLastMessageAsync(
        string groupId, CancellationToken cancellationToken = default);
    Task<IEnumerable<MessageDto>> GetMessagesByGroupIdAsync(
        string currentUserId, string groupId, CancellationToken cancellationToken = default);
}
