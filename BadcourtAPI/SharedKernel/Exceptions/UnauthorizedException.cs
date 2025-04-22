namespace SharedKernel.Exceptions;

public class UnauthorizedException(string message) : ApplicationException("Unauthorized", message)
{
}
