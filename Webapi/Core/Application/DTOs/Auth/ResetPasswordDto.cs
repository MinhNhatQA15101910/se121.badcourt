using System;

namespace Application.DTOs.Auth;

public class ResetPasswordDto
{
    public Guid? UserId { get; set; }
    public string NewPassword { get; set; } = string.Empty;
}
