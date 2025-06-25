using FluentValidation;

namespace OrderService.Core.Application.Commands.CreateRating;

public class CreateRatingValidator : AbstractValidator<CreateRatingCommand>
{
    public CreateRatingValidator()
    {
        RuleFor(x => x.OrderId)
            .NotEmpty().WithMessage("Order ID is required.")
            .NotNull().WithMessage("Order ID cannot be null.");

        RuleFor(x => x.CreateRatingDto.Stars)
            .InclusiveBetween(1, 5).WithMessage("Stars must be between 1 and 5.");

        RuleFor(x => x.CreateRatingDto.Feedback)
            .MaximumLength(500).WithMessage("Feedback cannot exceed 500 characters.");
    }
}
