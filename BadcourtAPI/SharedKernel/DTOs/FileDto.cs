namespace SharedKernel.DTOs;

public class FileDto
{
    public string? Id { get; set; }
    public string Url { get; set; } = string.Empty;
    public bool IsMain { get; set; }
    public string FileType { get; set; } = string.Empty;
}
