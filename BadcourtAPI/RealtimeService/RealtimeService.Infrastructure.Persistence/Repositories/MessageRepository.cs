using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;
using SharedKernel.DTOs;

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

    public async Task<IEnumerable<MessageDto>> GetMessageThreadAsync(
        string currentUserId,
        string recipientId,
        CancellationToken cancellationToken = default
    )
    {
        var query = _messages.AsQueryable()
            .Where(m =>
                (m.RecipientId == currentUserId && !m.RecipientDeleted && m.SenderId == recipientId) ||
                (m.SenderId == currentUserId && !m.SenderDeleted && m.RecipientId == recipientId))
            .OrderBy(m => m.MessageSent);

        var unreadMessages = query.Where(m =>
            m.DateRead == null &&
            m.RecipientId == currentUserId
        ).ToList();
        if (unreadMessages.Count != 0)
        {
            foreach (var message in unreadMessages)
            {
                message.DateRead = DateTime.UtcNow;
                await UpdateMessageAsync(message, cancellationToken);
            }
            unreadMessages.ForEach(m => m.DateRead = DateTime.UtcNow);
        }

        return await query.ProjectTo<MessageDto>(_mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);
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
