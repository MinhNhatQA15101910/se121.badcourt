using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RealtimeService.Application.Commands.ReadAllNotification;
using RealtimeService.Application.Commands.UpdateReadNotification;
using RealtimeService.Application.Queries.GetNotifications;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class NotificationsController(IMediator mediator) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<PagedResult<NotificationDto>>> GetNotifications(
        [FromQuery] NotificationParams notificationParams
    )
    {
        return await mediator.Send(new GetNotificationsQuery(notificationParams));
    }

    [HttpPut("read/{notificationId}")]
    public async Task<IActionResult> UpdateReadNotification(string notificationId)
    {
        await mediator.Send(new UpdateReadNotificationCommand(notificationId));
        return NoContent();
    }

    [HttpPut("read-all")]
    public async Task<IActionResult> ReadAllNotifications()
    {
        await mediator.Send(new ReadAllNotificationCommand());
        return NoContent();
    }
}
