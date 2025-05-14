using Microsoft.AspNetCore.Http;

namespace PostService.Application.Commands.CreatePost;

public class CreatePostDto
{
    public string? UserId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public IEnumerable<IFormFile> Resources { get; set; } = [];
}
