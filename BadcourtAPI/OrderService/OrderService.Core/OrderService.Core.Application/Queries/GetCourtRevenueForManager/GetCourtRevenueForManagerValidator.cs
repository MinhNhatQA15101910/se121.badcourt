using FluentValidation;

namespace OrderService.Core.Application.Queries.GetCourtRevenueForManager;

public class GetCourtRevenueForManagerValidator : AbstractValidator<GetCourtRevenueForManagerQuery>
{
    public GetCourtRevenueForManagerValidator()
    {
        RuleFor(query => query.CourtRevenueParams.FacilityId)
            .NotEmpty().WithMessage("Facility ID is required.");

        RuleFor(query => query.CourtRevenueParams.Year)
            .GreaterThan(0).WithMessage("Year must be a positive integer.");
    }
}
