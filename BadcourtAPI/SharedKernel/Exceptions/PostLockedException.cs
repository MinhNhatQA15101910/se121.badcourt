namespace SharedKernel.Exceptions;

public class PostLockedException(string postId)
    : ForbiddenAccessException($"Post with ID {postId} is locked and cannot be accessed.")
{
}
