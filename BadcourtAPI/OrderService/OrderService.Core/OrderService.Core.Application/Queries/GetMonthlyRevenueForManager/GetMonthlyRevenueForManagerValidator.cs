using FluentValidation;

namespace OrderService.Core.Application.Queries.GetMonthlyRevenueForManager;

public class GetMonthlyRevenueForManagerValidator : AbstractValidator<GetMonthlyRevenueForManagerQuery>
{
    public GetMonthlyRevenueForManagerValidator()
    {
        RuleFor(query => query.Params.FacilityId)
            .NotEmpty().WithMessage("Facility ID is required.")
            .NotNull().WithMessage("Facility ID cannot be null.");

        RuleFor(query => query.Params.Year)
            .GreaterThan(0).WithMessage("Year must be a positive integer.");
    }
}
