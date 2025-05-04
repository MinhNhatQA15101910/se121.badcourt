namespace FacilityService.Infrastructure.Configuration;

public class CloudinarySettings
{
    public required string CloudName { get; set; }
    public required string ApiKey { get; set; }
    public required string ApiSecret { get; set; }
    public required string FolderRoot { get; set; }
}
