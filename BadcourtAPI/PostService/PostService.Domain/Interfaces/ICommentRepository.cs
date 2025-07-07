using PostService.Domain.Entities;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace PostService.Domain.Interfaces;

public interface ICommentRepository
{
    Task CreateCommentAsync(Comment comment, CancellationToken cancellationToken = default);
    Task<List<Comment>> GetAllCommentsAsync(CommentParams commentParams, CancellationToken cancellationToken = default);
    Task<Comment?> GetCommentByIdAsync(string commentId, CancellationToken cancellationToken);
    Task<PagedList<CommentDto>> GetCommentsAsync(CommentParams commentParams, string? currentUserId, CancellationToken cancellationToken = default);
    Task UpdateCommentAsync(Comment comment, CancellationToken cancellationToken = default);
}
