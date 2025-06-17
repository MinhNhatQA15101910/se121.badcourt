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

public class OrderCreatedConsumer(
    INotificationRepository notificationRepository,
    IHubContext<NotificationHub> notificationHub,
    IHubContext<CourtHub> courtHub,
    NotificationHubTracker notificationHubTracker,
    IMapper mapper
) : IConsumer<OrderCreatedEvent>
{
    public async Task Consume(ConsumeContext<OrderCreatedEvent> context)
    {
        // Notify the user about the order creation
        var notification = new Notification
        {
            UserId = context.Message.UserId,
            Type = NotificationType.CourtBookingCreated,
            Title = "Court Booking Created",
            Content = $"Your court booking for court {context.Message.CourtId} has been created successfully. " +
                $"Date and time: {context.Message.DateTimePeriodDto.HourFrom} to {context.Message.DateTimePeriodDto.HourTo}.",
            Data = new NotificationData
            {
                OrderId = context.Message.OrderId,
            },
        };

        await notificationRepository.AddNotificationAsync(notification);

        var connections = await notificationHubTracker.GetConnectionsForUserAsync(context.Message.UserId);
        if (connections != null && connections.Count != 0)
        {
            var notificationDto = mapper.Map<NotificationDto>(notification);
            await notificationHub.Clients.Clients(connections).SendAsync("ReceiveNotification", notificationDto);
        }

        await courtHub.Clients.Group(context.Message.CourtId).SendAsync("NewOrderTimePeriod", context.Message.DateTimePeriodDto);

        Console.WriteLine("Notification sent for order creation.");
    }
}
