using RealtimeService.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Domain.Interfaces;

public interface IMessageRepository
{
    Task AddMessageAsync(
        Message message, CancellationToken cancellationToken = default);
    Task<Message?> GetLastMessageAsync(
        string groupId, CancellationToken cancellationToken = default);
    Task<PagedList<MessageDto>> GetMessagesAsync(
        string currentUserId, MessageParams messageParams, CancellationToken cancellationToken = default);
}
