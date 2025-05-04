using AuthService.Core.Domain.Enums;

namespace AuthService.Core.Application.DTOs;

public class VerifyPincodeDto
{
    public string Pincode { get; set; } = string.Empty;
    public string? Email { get; set; }
    public PincodeAction Action { get; set; }
}
