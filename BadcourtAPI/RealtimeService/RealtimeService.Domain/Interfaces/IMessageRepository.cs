using SharedKernel;
using SharedKernel.DTOs;

namespace RealtimeService.Domain.Interfaces;

public interface IMessageRepository
{
    Task<IEnumerable<MessageDto>> GetMessageThreadAsync(
        string currentUserId,
        string recipientId,
        CancellationToken cancellationToken = default
    );
}
