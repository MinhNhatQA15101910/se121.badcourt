namespace Domain.Exceptions;

public class BadRequestException(string message) : ApplicationException("Bad Request", message)
{
}
