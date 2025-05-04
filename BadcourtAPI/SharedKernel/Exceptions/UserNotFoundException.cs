namespace SharedKernel.Exceptions;

public class UserNotFoundException(Guid userId)
    : NotFoundException($"The user with the identifier {userId} was not found.")
{
}
