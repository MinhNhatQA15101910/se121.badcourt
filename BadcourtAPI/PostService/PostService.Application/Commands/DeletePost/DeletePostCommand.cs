namespace PostService.Application.Commands.DeletePost;

public record DeletePostCommand(string PostId) : ICommand<bool>;
