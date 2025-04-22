namespace SharedKernel.DTOs;

public class PhotoDto
{
    public string? Id { get; set; } 
    public string Url { get; set; } = string.Empty;
    public bool IsMain { get; set; }
}
