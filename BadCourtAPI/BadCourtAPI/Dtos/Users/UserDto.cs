using BadCourtAPI.Dtos.Photos;

namespace BadCourtAPI.Dtos.Users;

public class UserDto
{
    public Guid Id { get; set; }
    public required string Email { get; set; }
    public required string FullName { get; set; }
    public string? PhotoUrl { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<string> Roles { get; set; } = [];
    public List<PhotoDto> Photos { get; set; } = [];
    public string? Token { get; set; }
}
