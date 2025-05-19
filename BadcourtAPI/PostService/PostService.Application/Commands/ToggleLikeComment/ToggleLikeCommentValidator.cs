using FluentValidation;

namespace PostService.Application.Commands.ToggleLikeComment;

public class ToggleLikeCommentValidator : AbstractValidator<ToggleLikeCommentCommand>
{
    public ToggleLikeCommentValidator()
    {
        RuleFor(x => x.CommentId)
            .NotEmpty()
            .WithMessage("Comment ID cannot be empty.")
            .Matches("^[a-fA-F0-9]{24}$")
            .WithMessage("Comment ID must be a valid ObjectId.");
    }
}
