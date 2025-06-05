using Microsoft.AspNetCore.Http;
using RealtimeService.Application.Extensions;
using RealtimeService.Domain.Interfaces;
using SharedKernel;
using SharedKernel.DTOs;

namespace RealtimeService.Application.Queries.GetNotifications;

public class GetNotificationsHandler(
    IHttpContextAccessor httpContextAccessor,
    INotificationRepository notificationRepository
) : IQueryHandler<GetNotificationsQuery, PagedResult<NotificationDto>>
{
    public async Task<PagedResult<NotificationDto>> Handle(GetNotificationsQuery request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId().ToString();

        var notificationDtos = await notificationRepository.GetNotificationsAsync(
            userId, request.NotificationParams, cancellationToken);

        return new PagedResult<NotificationDto>
        {
            CurrentPage = notificationDtos.CurrentPage,
            TotalPages = notificationDtos.TotalPages,
            PageSize = notificationDtos.PageSize,
            TotalCount = notificationDtos.TotalCount,
            Items = notificationDtos
        };
    }
}
