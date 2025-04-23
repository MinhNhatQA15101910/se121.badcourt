namespace FacilityService.Core.Domain.Entities;

public class ManagerInfo
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string CitizenId { get; set; } = string.Empty;
    public Photo CitizenImageFront { get; set; } = new Photo();
    public Photo CitizenImageBack { get; set; } = new Photo();
    public Photo BankCardFront { get; set; } = new Photo();
    public Photo BankCardBack { get; set; } = new Photo();
    public IEnumerable<Photo> BusinessLicenseImages { get; set; } = [];
}
