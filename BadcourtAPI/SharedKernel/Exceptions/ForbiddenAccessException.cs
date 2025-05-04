namespace SharedKernel.Exceptions;

public class ForbiddenAccessException(string message) : ApplicationException("Forbidden", message)
{
}
