using System.ComponentModel.DataAnnotations;

namespace RealtimeService.Presentation.DTOs;

public class CreateMessageDto
{
    [Required]
    public string RecipientId { get; set; } = null!;

    [Required]
    public string Content { get; set; } = string.Empty;
}
