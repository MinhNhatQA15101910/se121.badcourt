namespace AuthService.Core.Application.DTOs;

public class ResetPasswordDto
{
    public Guid? UserId { get; set; }
    public string NewPassword { get; set; } = string.Empty;
}
