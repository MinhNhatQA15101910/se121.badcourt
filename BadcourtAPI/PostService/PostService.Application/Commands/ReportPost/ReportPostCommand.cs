namespace PostService.Application.Commands.ReportPost;

public record ReportPostCommand(string PostId) : ICommand<bool>;
