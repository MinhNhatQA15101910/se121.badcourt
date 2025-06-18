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
    }
}
