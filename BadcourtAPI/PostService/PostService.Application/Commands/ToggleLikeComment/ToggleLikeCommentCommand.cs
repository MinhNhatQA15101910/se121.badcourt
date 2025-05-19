namespace PostService.Application.Commands.ToggleLikeComment;

public record ToggleLikeCommentCommand(string CommentId) : ICommand<bool>;

