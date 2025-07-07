using AutoMapper;
using Microsoft.Extensions.Options;
using MongoDB.Bson;
using MongoDB.Driver;
using PostService.Domain.Entities;
using PostService.Domain.Enums;
using PostService.Domain.Interfaces;
using PostService.Infrastructure.Persistence.Configurations;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace PostService.Infrastructure.Persistence.Repositories;

public class PostRepository : IPostRepository
{
    private readonly IMongoCollection<Post> _posts;
    private readonly IMapper _mapper;

    public PostRepository(
        IOptions<PostDatabaseSettings> postDatabaseSettings,
        IMapper mapper
    )
    {
        var mongoClient = new MongoClient(postDatabaseSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(postDatabaseSettings.Value.DatabaseName);
        _posts = mongoDatabase.GetCollection<Post>(postDatabaseSettings.Value.PostsCollectionName);

        _mapper = mapper;
    }

    public async Task CreatePostAsync(Post post, CancellationToken cancellationToken = default)
    {
        await _posts.InsertOneAsync(post, cancellationToken: cancellationToken);
    }

    public Task<List<Post>> GetAllPostsAsync(PostParams postParams, CancellationToken cancellationToken = default)
    {
        var filter = Builders<Post>.Filter.Empty;

        // Filter by publisher id
        if (!string.IsNullOrEmpty(postParams.PublisherId))
        {
            filter &= Builders<Post>.Filter.Eq(p => p.PublisherId, Guid.Parse(postParams.PublisherId));
        }

        // Filter by category
        if (!string.IsNullOrEmpty(postParams.Category))
        {
            filter &= Builders<Post>.Filter.Eq(p => p.Category, Enum.Parse<PostCategory>(postParams.Category));
        }

        return _posts.Find(filter)
            .ToListAsync(cancellationToken: cancellationToken);
    }

    public async Task<Post?> GetPostByIdAsync(string postId, CancellationToken cancellationToken = default)
    {
        return await _posts
            .Find(p => p.Id == postId)
            .FirstOrDefaultAsync(cancellationToken: cancellationToken);
    }

    public async Task<PagedList<PostDto>> GetPostsAsync(PostParams postParams, string? currentUserId, CancellationToken cancellationToken = default)
    {
        var pipeline = new List<BsonDocument>();

        switch (postParams.OrderBy)
        {
            case "category":
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("Category", postParams.SortBy == "asc" ? 1 : -1)));
                break;
            case "createdAt":
            default:
                pipeline.Add(new BsonDocument("$sort", new BsonDocument("CreatedAt", postParams.SortBy == "asc" ? 1 : -1)));
                break;
        }

        // Filter by user id
        if (!string.IsNullOrEmpty(postParams.PublisherId))
        {
            pipeline.Add(new BsonDocument("$match", new BsonDocument("PublisherId", postParams.PublisherId)));
        }

        // Filter by category
        if (!string.IsNullOrEmpty(postParams.Category))
        {
            pipeline.Add(new BsonDocument("$match", new BsonDocument("Category", postParams.Category)));
        }

        var posts = await PagedList<Post>.CreateAsync(
            _posts,
            pipeline,
            postParams.PageNumber,
            postParams.PageSize,
            cancellationToken
        );

        var postDtos = PagedList<PostDto>.Map(posts, _mapper);
        if (!string.IsNullOrEmpty(currentUserId))
        {
            for (int i = 0; i < postDtos.Count; i++)
            {
                if (posts[i].LikedUsers.Contains(currentUserId))
                {
                    postDtos[i].IsLiked = true;
                }
            }
        }

        return postDtos;
    }

    public async Task UpdatePostAsync(Post post, CancellationToken cancellationToken = default)
    {
        await _posts.ReplaceOneAsync(
            p => p.Id == post.Id,
            post,
            cancellationToken: cancellationToken
        );
    }
}
