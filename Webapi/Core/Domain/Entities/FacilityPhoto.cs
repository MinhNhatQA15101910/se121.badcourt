using System.ComponentModel.DataAnnotations.Schema;

namespace Domain.Entities;

[Table("FacilityPhotos")]
public class FacilityPhoto
{
    public Guid Id { get; set; }
    public required string Url { get; set; }
    public string? PublicId { get; set; }
    public bool IsMain { get; set; }

    // Navigation properties
    public Guid FacilityId { get; set; }
    public Facility Facility { get; set; } = null!;
}
