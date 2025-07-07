namespace SharedKernel.Exceptions;

public class CommentLockedException(string commentId)
    : ForbiddenAccessException($"Comment with ID {commentId} is locked and cannot be accessed.")
{
}
