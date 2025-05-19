using FluentValidation;

namespace PostService.Application.Commands.CreateComment;

public class CreateCommentValidator : AbstractValidator<CreateCommentCommand>
{
    public CreateCommentValidator()
    {
        RuleFor(x => x.CreateCommentDto.PostId)
            .NotEmpty()
            .WithMessage("Post ID cannot be empty.")
            .Matches("^[a-fA-F0-9]{24}$")
            .WithMessage("Post ID must be a valid ObjectId.");

        RuleFor(x => x.CreateCommentDto.Content)
            .NotEmpty()
            .WithMessage("Content cannot be empty.")
            .MaximumLength(500)
            .WithMessage("Content cannot exceed 500 characters.");
    }
}
