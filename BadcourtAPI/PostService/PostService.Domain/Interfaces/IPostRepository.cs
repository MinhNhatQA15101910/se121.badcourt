using PostService.Domain.Entities;

namespace PostService.Domain.Interfaces;

public interface IPostRepository
{
    Task CreatePostAsync(Post post, CancellationToken cancellationToken = default);
}
