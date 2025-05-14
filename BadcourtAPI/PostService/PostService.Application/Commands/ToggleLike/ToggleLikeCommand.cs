namespace PostService.Application.Commands.ToggleLike;

public record ToggleLikeCommand(string PostId) : ICommand<bool>;
