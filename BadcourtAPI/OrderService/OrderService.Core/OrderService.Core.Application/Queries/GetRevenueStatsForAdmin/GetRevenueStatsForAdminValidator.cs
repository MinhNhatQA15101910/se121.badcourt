using FluentValidation;

namespace OrderService.Core.Application.Queries.GetRevenueStatsForAdmin;

public class GetRevenueStatsForAdminValidator : AbstractValidator<GetRevenueStatsForAdminQuery>
{
    public GetRevenueStatsForAdminValidator()
    {
        RuleFor(x => x.RevenueStatParams.Year)
            .GreaterThan(0)
            .WithMessage("Year must be greater than 0.");
    }
}
