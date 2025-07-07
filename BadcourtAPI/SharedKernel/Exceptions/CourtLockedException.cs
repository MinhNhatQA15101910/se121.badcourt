namespace SharedKernel.Exceptions;

public class CourtLockedException(string courtId)
    : ForbiddenAccessException($"Court with ID {courtId} is locked and cannot be accessed.")
{
}
