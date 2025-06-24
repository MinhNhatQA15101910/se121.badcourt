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

public class FacilityRejectedConsumer(
    INotificationRepository notificationRepository,
    NotificationHubTracker notificationHubTracker,
    IHubContext<NotificationHub> notificationHub,
    IMapper mapper
) : IConsumer<FacilityRejectedEvent>
{
    public async Task Consume(ConsumeContext<FacilityRejectedEvent> context)
    {
        var notification = new Notification
        {
            UserId = context.Message.ManagerId,
            Type = NotificationType.FacilityRejected,
            Title = "Facility Rejected",
            Content = $"Your facility '{context.Message.FacilityName}' has been rejected.",
            Data = new NotificationData
            {
                FacilityId = context.Message.FacilityId,
            },
        };

        await notificationRepository.AddNotificationAsync(notification);

        var connections = await notificationHubTracker.GetConnectionsForUserAsync(context.Message.ManagerId);
        if (connections != null && connections.Count != 0)
        {
            var notificationDto = mapper.Map<NotificationDto>(notification);
            await notificationHub.Clients.Clients(connections).SendAsync("ReceiveNotification", notificationDto);
        }

        Console.WriteLine("Notification sent for facility rejected.");
    }
}
