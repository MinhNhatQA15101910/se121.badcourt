using Microsoft.AspNetCore.Http;
using RealtimeService.Application.Extensions;
using RealtimeService.Domain.Interfaces;
using SharedKernel.Exceptions;

namespace RealtimeService.Application.Commands.UpdateReadNotification;

public class UpdateReadNotificationHandler(
    IHttpContextAccessor httpContextAccessor,
    INotificationRepository notificationRepository
) : ICommandHandler<UpdateReadNotificationCommand, bool>
{
    public async Task<bool> Handle(UpdateReadNotificationCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        var notification = await notificationRepository.GetNotificationByIdAsync(request.NotificationId, cancellationToken)
            ?? throw new NotificationNotFoundException(request.NotificationId);

        if (notification.UserId != userId)
        {
            throw new ForbiddenAccessException(
                $"User {userId} is not authorized to update notification {request.NotificationId}."
            );
        }

        notification.IsRead = true;
        await notificationRepository.UpdateNotificationAsync(notification, cancellationToken);

        return true;
    }
}
