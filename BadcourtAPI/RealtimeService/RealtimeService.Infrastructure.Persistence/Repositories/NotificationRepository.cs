using AutoMapper;
using Microsoft.Extensions.Options;
using MongoDB.Bson;
using MongoDB.Driver;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Infrastructure.Persistence.Repositories;

public class NotificationRepository : INotificationRepository
{
    private readonly IMongoCollection<Notification> _notifications;
    private readonly IMapper _mapper;

    public NotificationRepository(
        IOptions<RealtimeDatabaseSettings> realtimeDatabaseSettings,
        IMapper mapper
    )
    {
        var mongoClient = new MongoClient(realtimeDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(realtimeDatabaseSettings.Value.DatabaseName);
        _notifications = mongoDatabase.GetCollection<Notification>(realtimeDatabaseSettings.Value.NotificationsCollectionName);

        _mapper = mapper;
    }

    public async Task AddNotificationAsync(Notification notification, CancellationToken cancellationToken = default)
    {
        await _notifications.InsertOneAsync(notification, cancellationToken: cancellationToken);
    }

    public async Task<PagedList<NotificationDto>> GetNotificationsAsync(string userId, NotificationParams notificationParams, CancellationToken cancellationToken = default)
    {
        var pipeline = new List<BsonDocument>
        {
            new("$match", new BsonDocument("UserId", userId))
        };

        switch (notificationParams.OrderBy)
        {
            case "createdAt":
            default:
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("CreatedAt", notificationParams.SortBy == "asc" ? 1 : -1)));
                break;
        }

        var notifications = await PagedList<Notification>.CreateAsync(
            _notifications,
            pipeline,
            notificationParams.PageNumber,
            notificationParams.PageSize,
            cancellationToken
        );

        return PagedList<NotificationDto>.Map(notifications, _mapper);
    }

    public Task<int> GetNumberOfUnreadNotificationsAsync(string userId, CancellationToken cancellationToken = default)
    {
        var filter = Builders<Notification>.Filter.And(
            Builders<Notification>.Filter.Eq(n => n.UserId, userId),
            Builders<Notification>.Filter.Eq(n => n.IsRead, false)
        );

        return _notifications.CountDocumentsAsync(filter, cancellationToken: cancellationToken)
            .ContinueWith(task => (int)task.Result, cancellationToken);
    }
}
