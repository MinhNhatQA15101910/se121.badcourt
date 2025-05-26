using RealtimeService.Domain.Entities;
using SharedKernel.DTOs;

namespace RealtimeService.Domain.Interfaces;

public interface IMessageRepository
{
    Task AddMessageAsync(
        Message message,
        CancellationToken cancellationToken = default
    );
    Task<Message?> GetLastMessageAsync(string groupId, CancellationToken cancellationToken = default);
    Task<IEnumerable<MessageDto>> GetMessageThreadAsync(
        string currentUserId,
        string recipientId,
        CancellationToken cancellationToken = default
    );
}
