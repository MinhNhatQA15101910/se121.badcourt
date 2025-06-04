using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
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

    public async Task<PagedList<MessageDto>> GetMessagesAsync(MessageParams messageParams, CancellationToken cancellationToken = default)
    {
        var query = _messages.AsQueryable()
            .Where(m => m.GroupId == messageParams.GroupId);

        if (messageParams.OrderBy == "messageSent")
        {
            query = messageParams.SortBy == "asc" ? query.OrderBy(m => m.MessageSent) : query.OrderByDescending(m => m.MessageSent);
        }

        var unreadMessages = query.Where(m =>
            m.DateRead == null &&
            m.SenderId != messageParams.CurrentUserId
        ).ToList();
        if (unreadMessages.Count != 0)
        {
            foreach (var message in unreadMessages)
            {
                message.DateRead = DateTime.UtcNow;
                await UpdateMessageAsync(message, cancellationToken);
            }
        }

        var messages = query.ProjectTo<MessageDto>(_mapper.ConfigurationProvider);

        return await PagedList<MessageDto>.CreateAsync(messages, messageParams.PageNumber, messageParams.PageSize, cancellationToken);
    }

    private async Task UpdateMessageAsync(Message message, CancellationToken cancellationToken = default)
    {
        await _messages.ReplaceOneAsync(
            m => m.Id == message.Id,
            message,
            cancellationToken: cancellationToken
        );
    }
}
