using PostService.Domain.Entities;

namespace PostService.Domain.Interfaces;

public interface ICommentRepository
{
    Task CreateCommentAsync(Comment comment, CancellationToken cancellationToken);
    Task UpdateCommentAsync(Comment comment, CancellationToken cancellationToken);
}
