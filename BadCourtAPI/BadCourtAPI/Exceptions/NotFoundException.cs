namespace BadCourtAPI.Exceptions;

public abstract class NotFoundException(string message) : ApplicationException("Not Found", message)
{
}
