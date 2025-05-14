namespace SharedKernel.DTOs;

public class PostDto
{
    public string Id { get; set; } = null!;
    public Guid UserId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public IEnumerable<FileDto> Resources { get; set; } = [];
    public int LikesCount { get; set; }
    public int CommentsCount { get; set; }
    public bool IsLiked { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
