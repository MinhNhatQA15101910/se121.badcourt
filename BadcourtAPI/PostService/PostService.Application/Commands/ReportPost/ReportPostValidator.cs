using FluentValidation;

namespace PostService.Application.Commands.ReportPost;

public class ReportPostValidator : AbstractValidator<ReportPostCommand>
{
    public ReportPostValidator()
    {
        RuleFor(x => x.PostId)
            .NotEmpty()
            .WithMessage("Post ID cannot be empty.")
            .Matches("^[a-fA-F0-9]{24}$")
            .WithMessage("Post ID must be a valid ObjectId.");
    }
}
