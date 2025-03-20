using System.ComponentModel.DataAnnotations.Schema;

namespace FacilityService.Core.Domain.Entities;

[Table("BusinessLicensePhotos")]
public class BusinessLicensePhoto
{
    public Guid Id { get; set; }
    public required string Url { get; set; }
    public string? PublicId { get; set; }
    public bool IsMain { get; set; }

    // Navigation properties
    public Guid ManagerInfoId { get; set; }
    public ManagerInfo ManagerInfo { get; set; } = null!;
}
