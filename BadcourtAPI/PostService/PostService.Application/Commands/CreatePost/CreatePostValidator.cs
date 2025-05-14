using FluentValidation;

namespace PostService.Application.Commands.CreatePost;

public class CreatePostValidator : AbstractValidator<CreatePostCommand>
{
    public CreatePostValidator()
    {
        RuleFor(x => x.CreatePostDto.Title)
            .NotEmpty()
            .WithMessage("Title is required.")
            .MaximumLength(100)
            .WithMessage("Title must not exceed 100 characters.");

        RuleFor(x => x.CreatePostDto.Content)
            .NotEmpty()
            .WithMessage("Content is required.")
            .MaximumLength(5000)
            .WithMessage("Content must not exceed 5000 characters.");
    }
}
