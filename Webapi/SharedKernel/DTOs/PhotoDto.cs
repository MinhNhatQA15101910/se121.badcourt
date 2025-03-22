namespace SharedKernel.DTOs;

public class PhotoDto
{
    public Guid Id { get; set; }
    public string Url { get; set; } = string.Empty;
    public bool IsMain { get; set; }
}
