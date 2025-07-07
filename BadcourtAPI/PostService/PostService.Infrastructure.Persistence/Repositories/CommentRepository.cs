using AutoMapper;
using Microsoft.Extensions.Options;
using MongoDB.Bson;
using MongoDB.Driver;
using PostService.Domain.Entities;
using PostService.Domain.Interfaces;
using PostService.Infrastructure.Persistence.Configurations;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

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

    public Task<List<Comment>> GetAllCommentsAsync(CommentParams commentParams, CancellationToken cancellationToken = default)
    {
        var filter = Builders<Comment>.Filter.Empty;

        // Filter by publisher id
        if (!string.IsNullOrEmpty(commentParams.PublisherId))
        {
            filter &= Builders<Comment>.Filter.Eq(c => c.PublisherId, Guid.Parse(commentParams.PublisherId));
        }

        // Filter by post id
        if (!string.IsNullOrEmpty(commentParams.PostId))
        {
            filter &= Builders<Comment>.Filter.Eq(c => c.PostId, commentParams.PostId);
        }

        return _comments.Find(filter)
            .Sort(Builders<Comment>.Sort.Descending(c => c.CreatedAt))
            .ToListAsync(cancellationToken: cancellationToken);
    }

    public async Task<Comment?> GetCommentByIdAsync(string commentId, CancellationToken cancellationToken)
    {
        return await _comments
            .Find(c => c.Id == commentId)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<PagedList<CommentDto>> GetCommentsAsync(CommentParams commentParams, string? currentUserId, CancellationToken cancellationToken = default)
    {
        var pipeline = new List<BsonDocument>();

        switch (commentParams.OrderBy)
        {
            case "createdAt":
            default:
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("CreatedAt", commentParams.SortBy == "asc" ? 1 : -1)));
                break;
        }

        // Filter by publisherId
        if (!string.IsNullOrEmpty(commentParams.PublisherId))
        {
            pipeline.Add(new BsonDocument("$match", new BsonDocument("PublisherId", commentParams.PublisherId)));
        }

        // Filter by postId
        if (!string.IsNullOrEmpty(commentParams.PostId))
        {
            pipeline.Add(new BsonDocument("$match", new BsonDocument("PostId", commentParams.PostId)));
        }

        var comments = await PagedList<Comment>.CreateAsync(
            _comments,
            pipeline,
            commentParams.PageNumber,
            commentParams.PageSize,
            cancellationToken
        );

        var commentDtos = PagedList<CommentDto>.Map(comments, _mapper);
        if (!string.IsNullOrEmpty(currentUserId))
        {
            for (int i = 0; i < commentDtos.Count; i++)
            {
                if (comments[i].LikedUsers.Contains(currentUserId))
                {
                    commentDtos[i].IsLiked = true;
                }
            }
        }

        return commentDtos;
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
