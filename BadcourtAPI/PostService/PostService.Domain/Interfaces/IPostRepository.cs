using PostService.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace PostService.Domain.Interfaces;

public interface IPostRepository
{
    Task CreatePostAsync(Post post, CancellationToken cancellationToken = default);
    Task<Post?> GetPostByIdAsync(string postId, CancellationToken cancellationToken = default);
    Task<PagedList<PostDto>> GetPostsAsync(PostParams postParams, CancellationToken cancellationToken = default);
    Task UpdatePostAsync(Post post, CancellationToken cancellationToken = default);
}
