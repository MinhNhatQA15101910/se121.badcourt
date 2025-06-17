using AutoMapper;
using MassTransit;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Enums;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.SignalR;
using SharedKernel.DTOs;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace RealtimeService.Presentation.Consumers;

public class OrderCreatedConsumer(
    INotificationRepository notificationRepository,
    IHubContext<PresenceHub> presenceHub,
    ICourtRepository courtRepository,
    IHubContext<CourtHub> courtHub,
    IMapper mapper
) : IConsumer<OrderCreatedEvent>
{
    public async Task Consume(ConsumeContext<OrderCreatedEvent> context)
    {
        // Update court
        await UpdateCourtAsync(context);

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

        var connections = await PresenceTracker.GetConnectionsForUser(context.Message.UserId);
        if (connections != null && connections.Count != 0)
        {
            var notificationDto = mapper.Map<NotificationDto>(notification);
            await presenceHub.Clients.Clients(connections).SendAsync("ReceiveNotification", notificationDto);
        }

        await courtHub.Clients.Group(context.Message.CourtId).SendAsync("NewOrderTimePeriod", context.Message.DateTimePeriodDto);

        Console.WriteLine("Notification sent for order creation.");
    }

    private async Task UpdateCourtAsync(ConsumeContext<OrderCreatedEvent> context)
    {
        var court = await courtRepository.GetCourtByIdAsync(context.Message.CourtId)
            ?? throw new CourtNotFoundException(context.Message.CourtId);

        court.OrderPeriods = [
            ..court.OrderPeriods,
            mapper.Map<DateTimePeriod>(context.Message.DateTimePeriodDto)
        ];

        court.UpdatedAt = DateTime.UtcNow;

        await courtRepository.UpdateCourtAsync(court);

        Console.WriteLine("Court updated with new order period.");
    }
}
