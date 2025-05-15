namespace PostService.Application.Commands.ToggleLikePost;

public record ToggleLikePostCommand(string PostId) : ICommand<bool>;
