using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Application.Queries.GetNotifications;

public record GetNotificationsQuery(NotificationParams NotificationParams) : IQuery<PagedResult<NotificationDto>>;
