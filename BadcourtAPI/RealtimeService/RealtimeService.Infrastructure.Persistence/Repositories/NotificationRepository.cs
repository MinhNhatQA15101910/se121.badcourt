using AutoMapper;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;

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

    public async Task<List<Notification>> GetNotificationsAsync(string userId, CancellationToken cancellationToken = default)
    {
        var filter = Builders<Notification>.Filter.Eq(n => n.UserId, userId);
        return await _notifications.Find(filter)
            .SortByDescending(n => n.CreatedAt)
            .ToListAsync(cancellationToken);
    }
}
