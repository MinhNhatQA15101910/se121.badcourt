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

public class PostLikedConsumer(
    INotificationRepository notificationRepository,
    IHubContext<NotificationHub> notificationHub,
    IMapper mapper
) : IConsumer<PostLikedEvent>
{
    public async Task Consume(ConsumeContext<PostLikedEvent> context)
    {
        var notification = new Notification
        {
            UserId = context.Message.PostOwnerId,
            Type = NotificationType.PostLiked,
            Title = "Post Liked",
            Content = $"{context.Message.LikedUserUsername} liked your post.",
            Data = new NotificationData
            {
                PostId = context.Message.PostId,
            },
        };

        await notificationRepository.AddNotificationAsync(notification);

        var connections = await PresenceTracker.GetConnectionsForUser(context.Message.PostOwnerId);
        if (connections != null && connections.Count != 0)
        {
            var notificationDto = mapper.Map<NotificationDto>(notification);
            await notificationHub.Clients.Clients(connections).SendAsync("ReceiveNotification", notificationDto);
        }

        Console.WriteLine("Notification sent for post liked.");
    }
}
