namespace SharedKernel.Exceptions;

public class CourtNotFoundException(string courtId)
    : NotFoundException($"The court with the identifier {courtId} was not found.")
{
}
