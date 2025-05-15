using Microsoft.AspNetCore.Http;

namespace PostService.Application.Commands.CreateComment;

public class CreateCommentDto
{
    public string PostId { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public IEnumerable<IFormFile> Resources { get; set; } = [];
}
