using AutoMapper;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using PostService.Domain.Entities;
using PostService.Domain.Interfaces;
using PostService.Infrastructure.Persistence.Configurations;

namespace PostService.Infrastructure.Persistence.Repositories;

public class CommentRepository : ICommentRepository
{
    private readonly IMongoCollection<Comment> _comments;
    private readonly IMapper _mapper;

    public CommentRepository(
        IOptions<PostDatabaseSettings> postDatabaseSettings,
        IMapper mapper
    )
    {
        var mongoClient = new MongoClient(postDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(postDatabaseSettings.Value.DatabaseName);
        _comments = mongoDatabase.GetCollection<Comment>(postDatabaseSettings.Value.CommentsCollectionName);

        _mapper = mapper;
    }

    public async Task CreateCommentAsync(Comment comment, CancellationToken cancellationToken)
    {
        await _comments.InsertOneAsync(comment, cancellationToken: cancellationToken);
    }

    public async Task UpdateCommentAsync(Comment comment, CancellationToken cancellationToken)
    {
        await _comments.ReplaceOneAsync(
            c => c.Id == comment.Id,
            comment,
            cancellationToken: cancellationToken
        );
    }
}
