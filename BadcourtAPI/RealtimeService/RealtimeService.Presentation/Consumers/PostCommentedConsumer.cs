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

public class PostCommentedConsumer(
    INotificationRepository notificationRepository,
    IHubContext<NotificationHub> notificationHub,
    NotificationHubTracker notificationHubTracker,
    IMapper mapper
) : IConsumer<PostCommentedEvent>
{
    public async Task Consume(ConsumeContext<PostCommentedEvent> context)
    {
        var notification = new Notification
        {
            UserId = context.Message.PostOwnerId,
            Type = NotificationType.PostCommented,
            Title = "Post Liked",
            Content = $"{context.Message.CommentedUserUsername} commented on your post: {context.Message.CommentContent}",
            Data = new NotificationData
            {
                PostId = context.Message.PostId,
            },
        };

        await notificationRepository.AddNotificationAsync(notification);

        var connections = await notificationHubTracker.GetConnectionsForUserAsync(context.Message.PostOwnerId);
        if (connections != null && connections.Count != 0)
        {
            var notificationDto = mapper.Map<NotificationDto>(notification);
            await notificationHub.Clients.Clients(connections).SendAsync("ReceiveNotification", notificationDto);
        }

        Console.WriteLine("Notification sent for post commented.");
    }
}
