namespace SharedKernel.DTOs;

public class ManagerInfoDto
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string CitizenId { get; set; } = string.Empty;
    public PhotoDto CitizenImageFront { get; set; } = null!;
    public PhotoDto CitizenImageBack { get; set; } = null!;
    public PhotoDto BankCardFront { get; set; } = null!;
    public PhotoDto BankCardBack { get; set; } = null!;
    public IEnumerable<PhotoDto> BusinessLicenseImages { get; set; } = [];
}
