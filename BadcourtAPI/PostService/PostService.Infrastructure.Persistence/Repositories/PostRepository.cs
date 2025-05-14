using AutoMapper;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using PostService.Domain.Entities;
using PostService.Domain.Interfaces;
using PostService.Infrastructure.Persistence.Configurations;

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

    public async Task<Post?> GetPostByIdAsync(string postId, CancellationToken cancellationToken = default)
    {
        return await _posts
            .Find(p => p.Id == postId)
            .FirstOrDefaultAsync(cancellationToken: cancellationToken);
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
