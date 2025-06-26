namespace SharedKernel.Exceptions;

public class RatingNotFoundException(Guid ratingId)
    : NotFoundException($"The rating with the identifier {ratingId} was not found.")
{
}
