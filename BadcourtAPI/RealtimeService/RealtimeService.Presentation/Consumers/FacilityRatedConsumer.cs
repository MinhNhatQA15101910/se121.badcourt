using AutoMapper;
using MassTransit;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Enums;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.SignalR;
using SharedKernel.DTOs;
using SharedKernel.Events;

namespace RealtimeService.Presentation.Consumers;

public class FacilityRatedConsumer(
    INotificationRepository notificationRepository,
    NotificationHubTracker notificationHubTracker,
    IHubContext<NotificationHub> notificationHub,
    IMapper mapper
) : IConsumer<FacilityRatedEvent>
{
    public async Task Consume(ConsumeContext<FacilityRatedEvent> context)
    {
        var notification = new Notification
        {
            UserId = context.Message.FacilityOwnerId,
            Type = NotificationType.FacilityRated,
            Title = "Facility Rated",
            Content = $"Your facility '{context.Message.FacilityId}' has been rated with {context.Message.Stars} stars.",
            Data = new NotificationData
            {
                FacilityId = context.Message.FacilityId,
            },
        };

        await notificationRepository.AddNotificationAsync(notification);

        var connections = await notificationHubTracker.GetConnectionsForUserAsync(context.Message.FacilityOwnerId);
        if (connections != null && connections.Count != 0)
        {
            var notificationDto = mapper.Map<NotificationDto>(notification);
            await notificationHub.Clients.Clients(connections).SendAsync("ReceiveNotification", notificationDto);
        }

        Console.WriteLine("Notification sent for facility rated.");
    }
}
