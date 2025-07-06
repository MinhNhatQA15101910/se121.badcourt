namespace SharedKernel.Exceptions;

public class UserLockedException(string userId)
    : ForbiddenAccessException($"User with ID {userId} is locked and cannot be accessed.")
{
}
