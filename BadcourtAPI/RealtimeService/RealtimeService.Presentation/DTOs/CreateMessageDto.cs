using System.ComponentModel.DataAnnotations;

namespace RealtimeService.Presentation.DTOs;

public class CreateMessageDto
{
    [Required]
    public string RecipientId { get; set; } = null!;

    public string Content { get; set; } = string.Empty;

    public List<IFormFile> Resources { get; set; } = [];
}
