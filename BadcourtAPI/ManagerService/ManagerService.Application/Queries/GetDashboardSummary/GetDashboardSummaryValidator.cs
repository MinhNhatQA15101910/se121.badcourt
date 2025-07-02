using FluentValidation;

namespace ManagerService.Application.Queries.GetDashboardSummary;

public class GetDashboardSummaryValidator : AbstractValidator<GetDashboardSummaryQuery>
{
    public GetDashboardSummaryValidator()
    {
        RuleFor(query => query.SummaryParams.FacilityId)
            .NotEmpty()
            .WithMessage("Facility ID is required.");
    }
}
