using Microsoft.AspNetCore.Http;

namespace FacilityService.Core.Application.DTOs;

public class UpdateFacilityDto
{
    public string? FacilityName { get; set; }
    public double? Lat { get; set; }
    public double? Lon { get; set; }
    public string? Description { get; set; }
    public string? Policy { get; set; }
    public string? DetailAddress { get; set; }
    public string? Province { get; set; }
    public string? FullName { get; set; }
    public string? Email { get; set; }
    public string? PhoneNumber { get; set; }
    public string? CitizenId { get; set; }
    public string? FacebookUrl { get; set; }
    public List<IFormFile> FacilityImages { get; set; } = [];
    public IFormFile? CitizenImageFront { get; set; }
    public IFormFile? CitizenImageBack { get; set; }
    public IFormFile? BankCardFront { get; set; }
    public IFormFile? BankCardBack { get; set; }
    public List<IFormFile> BusinessLicenseImages { get; set; } = [];
}
