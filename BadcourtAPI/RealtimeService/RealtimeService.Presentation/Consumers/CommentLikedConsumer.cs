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

public class CommentLikedConsumer(
    INotificationRepository notificationRepository,
    IHubContext<NotificationHub> notificationHub,
    NotificationHubTracker notificationHubTracker,
    IMapper mapper
) : IConsumer<CommentLikedEvent>
{
    public async Task Consume(ConsumeContext<CommentLikedEvent> context)
    {
        var notification = new Notification
        {
            UserId = context.Message.CommentOwnerId,
            Type = NotificationType.CommentLiked,
            Title = "Comment Liked",
            Content = $"{context.Message.LikedUserUsername} liked your comment.",
            Data = new NotificationData
            {
                CommentId = context.Message.CommentId,
            },
        };

        await notificationRepository.AddNotificationAsync(notification);

        var connections = await notificationHubTracker.GetConnectionsForUserAsync(context.Message.CommentOwnerId);
        if (connections != null && connections.Count != 0)
        {
            var notificationDto = mapper.Map<NotificationDto>(notification);
            await notificationHub.Clients.Clients(connections).SendAsync("ReceiveNotification", notificationDto);
        }

        Console.WriteLine("Notification sent for comment liked.");
    }
}
