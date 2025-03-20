namespace AuthService.Core.Domain.Exceptions;

public class UnauthorizedException(string message) : ApplicationException("Unauthorized", message)
{
}
