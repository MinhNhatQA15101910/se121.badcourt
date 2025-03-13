namespace BadCourtAPI.Exceptions;

public class ProductNotFoundException(Guid userId)
    : NotFoundException($"The product with the identifier {userId} was not found.")
{
}
