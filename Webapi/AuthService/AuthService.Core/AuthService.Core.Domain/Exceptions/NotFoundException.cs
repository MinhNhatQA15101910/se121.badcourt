namespace AuthService.Core.Domain.Exceptions;

public abstract class NotFoundException(string message) : ApplicationException("Not Found", message)
{
}
