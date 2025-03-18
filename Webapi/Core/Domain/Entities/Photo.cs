namespace Domain.Entities;

public class Photo
{
    public string Url { get; set; } = string.Empty;
    public string? PublicId { get; set; }
    public bool IsMain { get; set; }
}
