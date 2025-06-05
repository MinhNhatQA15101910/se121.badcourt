using Microsoft.AspNetCore.Http;
using RealtimeService.Application.Extensions;
using RealtimeService.Domain.Interfaces;
using SharedKernel;
using SharedKernel.DTOs;

namespace RealtimeService.Application.Queries.GetMessages;

public class GetMessagesHandler(
    IHttpContextAccessor httpContextAccessor,
    IMessageRepository messageRepository
) : IQueryHandler<GetMessagesQuery, PagedResult<MessageDto>>
{
    public async Task<PagedResult<MessageDto>> Handle(GetMessagesQuery request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId().ToString();

        var messages = await messageRepository.GetMessagesAsync(userId, request.MessageParams, cancellationToken);

        return new PagedResult<MessageDto>
        {
            CurrentPage = messages.CurrentPage,
            TotalPages = messages.TotalPages,
            PageSize = messages.PageSize,
            TotalCount = messages.TotalCount,
            Items = messages
        };
    }
}
