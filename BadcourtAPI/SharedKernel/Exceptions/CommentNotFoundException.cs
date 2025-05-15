namespace SharedKernel.Exceptions;

public class CommentNotFoundException(string commentId)
    : NotFoundException($"The comment with the identifier {commentId} was not found.")
{
}
