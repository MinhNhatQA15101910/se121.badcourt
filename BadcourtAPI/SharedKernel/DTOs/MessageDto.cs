namespace SharedKernel.DTOs;

public class MessageDto
{
    public string Id { get; set; } = null!;
    public string SenderId { get; set; } = null!;
    public string SenderUsername { get; set; } = string.Empty;
    public string SenderMessageUrl { get; set; } = string.Empty;
    public string RecipientId { get; set; } = null!;
    public string RecipientUsername { get; set; } = string.Empty;
    public string RecipientPhotoUrl { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime? DateRead { get; set; }
    public DateTime MessageSent { get; set; }
}
