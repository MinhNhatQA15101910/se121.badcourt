using AuthService.Core.Application.Queries;
using FluentValidation;

namespace AuthService.Core.Application.Validators;

public class GetUserStatsForAdminValidator : AbstractValidator<GetUserStatsForAdminQuery>
{
    public GetUserStatsForAdminValidator()
    {
        RuleFor(x => x.UserStatParams.Year)
            .GreaterThan(0)
            .WithMessage("Year must be greater than 0.");
    }
}
