namespace SharedKernel.DTOs;

public class CommentDto
{
    public string Id { get; set; } = null!;
    public Guid PublisherId { get; set; }
    public string PostId { get; set; } = null!;
    public string PublisherUsername { get; set; } = string.Empty;
    public string PublisherImageUrl { get; set; } = string.Empty;
    public string PublisherState { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public IEnumerable<FileDto> Resources { get; set; } = [];
    public int LikesCount { get; set; }
    public bool IsLiked { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
