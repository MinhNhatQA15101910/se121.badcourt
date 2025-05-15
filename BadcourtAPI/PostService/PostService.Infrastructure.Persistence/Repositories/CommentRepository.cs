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
