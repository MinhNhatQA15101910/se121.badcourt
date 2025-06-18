using Microsoft.AspNetCore.Http;
using RealtimeService.Application.Extensions;
using RealtimeService.Domain.Interfaces;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace RealtimeService.Application.Queries.GetMessages;

public class GetMessagesHandler(
    IHttpContextAccessor httpContextAccessor,
    IGroupRepository groupRepository,
    IMessageRepository messageRepository
) : IQueryHandler<GetMessagesQuery, PagedResult<MessageDto>>
{
    public async Task<PagedResult<MessageDto>> Handle(GetMessagesQuery request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId().ToString();

        if (string.IsNullOrEmpty(request.MessageParams.GroupId))
        {
            var otherUserId = request.MessageParams.OtherUserId
                ?? throw new BadRequestException("You must provide a group ID or an other user ID.");

            var groupName = GetGroupName(userId, otherUserId);
            var group = await groupRepository.GetGroupByNameAsync(groupName, cancellationToken)
                ?? throw new GroupNotFoundException(groupName);

            request.MessageParams.GroupId = group.Id;
        }

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

    private static string GetGroupName(string caller, string? other)
    {
        var stringCompare = string.CompareOrdinal(caller, other) < 0;
        return stringCompare ? $"{caller}-{other}" : $"{other}-{caller}";
    }
}
