namespace SharedKernel.DTOs;

public class GroupDto
{
    public string Id { get; set; } = null!;
    public string Name { get; set; } = string.Empty;
    public List<UserDto> Users { get; set; } = [];
    public MessageDto? LastMessage { get; set; }
    public List<ConnectionDto> Connections { get; set; } = [];
    public DateTime UpdatedAt { get; set; }
}
