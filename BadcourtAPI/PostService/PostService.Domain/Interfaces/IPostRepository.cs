using PostService.Domain.Entities;

namespace PostService.Domain.Interfaces;

public interface IPostRepository
{
    Task CreatePostAsync(Post post, CancellationToken cancellationToken = default);
    Task<Post?> GetPostByIdAsync(string postId, CancellationToken cancellationToken = default);
    Task UpdatePostAsync(Post post, CancellationToken cancellationToken = default);
}
