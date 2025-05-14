namespace SharedKernel.Exceptions;

public class PostNotFoundExceptions(string postId)
    : NotFoundException($"The post with the identifier {postId} was not found.")
{
}
