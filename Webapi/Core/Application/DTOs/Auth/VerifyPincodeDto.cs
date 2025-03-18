using Domain.Enums;

namespace Application.DTOs.Auth;

public class VerifyPincodeDto
{
    public string Pincode { get; set; } = string.Empty;
    public string? Email { get; set; }
    public PincodeAction Action { get; set; }
}
