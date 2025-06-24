using AutoMapper;
using Microsoft.EntityFrameworkCore;
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

public class MessageRepository : IMessageRepository
{
    private readonly IMongoCollection<Message> _messages;
    private readonly IMapper _mapper;

    public MessageRepository(
        IOptions<RealtimeDatabaseSettings> realtimeDatabaseSettings,
        IMapper mapper
    )
    {
        var mongoClient = new MongoClient(realtimeDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(realtimeDatabaseSettings.Value.DatabaseName);
        _messages = mongoDatabase.GetCollection<Message>(realtimeDatabaseSettings.Value.MessagesCollectionName);

        _mapper = mapper;
    }

    public async Task AddMessageAsync(Message message, CancellationToken cancellationToken = default)
    {
        await _messages.InsertOneAsync(message, cancellationToken: cancellationToken);
    }

    public async Task<Message?> GetLastMessageAsync(string groupId, CancellationToken cancellationToken = default)
    {
        return await _messages
            .Find(m => m.GroupId == groupId)
            .SortByDescending(m => m.MessageSent)
            .Limit(1)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<PagedList<MessageDto>> GetMessagesAsync(string currentUserId, MessageParams messageParams, CancellationToken cancellationToken = default)
    {
        var pipeline = new List<BsonDocument>
        {
            new("$match", new BsonDocument("GroupId", messageParams.GroupId))
        };

        await UpdateUnreadMessagesAsync(messageParams.GroupId, currentUserId, cancellationToken);

        switch (messageParams.OrderBy)
        {
            case "messageSent":
            default:
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("MessageSent", messageParams.SortBy == "asc" ? 1 : -1)));
                break;
        }

        var messages = await PagedList<Message>.CreateAsync(
            _messages,
            pipeline,
            messageParams.PageNumber,
            messageParams.PageSize,
            cancellationToken
        );

        return PagedList<MessageDto>.Map(messages, _mapper);
    }

    private async Task UpdateUnreadMessagesAsync(string groupId, string currentUserId, CancellationToken cancellationToken = default)
    {
        var unreadMessages = await _messages
            .Find(m => m.GroupId == groupId && m.DateRead == null && m.SenderId != currentUserId)
            .ToListAsync(cancellationToken);

        if (unreadMessages.Count > 0)
        {
            foreach (var message in unreadMessages)
            {
                message.DateRead = DateTime.UtcNow;
                await UpdateMessageAsync(message, cancellationToken);
            }
        }
    }

    public async Task UpdateMessageAsync(Message message, CancellationToken cancellationToken = default)
    {
        await _messages.ReplaceOneAsync(
            m => m.Id == message.Id,
            message,
            cancellationToken: cancellationToken
        );
    }

    public Task<int> GetNumberOfUnreadMessagesAsync(string currentUserId, CancellationToken cancellationToken = default)
    {
        var filter = Builders<Message>.Filter.And(
            Builders<Message>.Filter.Eq(m => m.ReceiverId, currentUserId),
            Builders<Message>.Filter.Eq(m => m.DateRead, null)
        );

        return _messages.CountDocumentsAsync(filter, cancellationToken: cancellationToken)
            .ContinueWith(task => (int)task.Result, cancellationToken);
    }
}
