namespace SharedKernel.DTOs;

public class MessageDto
{
    public string Id { get; set; } = null!;
    public string GroupId { get; set; } = null!;
    public string SenderId { get; set; } = null!;
    public string SenderUsername { get; set; } = string.Empty;
    public string SenderImageUrl { get; set; } = string.Empty;
    public string ReceiverId { get; set; } = null!;
    public string Content { get; set; } = string.Empty;
    public DateTime? DateRead { get; set; }
    public DateTime MessageSent { get; set; }
    public List<FileDto> Resources { get; set; } = [];
}
