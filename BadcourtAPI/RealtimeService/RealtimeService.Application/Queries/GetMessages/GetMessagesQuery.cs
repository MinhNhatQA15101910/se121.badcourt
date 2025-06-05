using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Application.Queries.GetMessages;

public record GetMessagesQuery(MessageParams MessageParams) : IQuery<PagedResult<MessageDto>>;
