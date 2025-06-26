using Microsoft.AspNetCore.Http;

namespace FacilityService.Core.Application.DTOs;

public class RegisterFacilityDto
{
    public required string FacilityName { get; set; }
    public double Lat { get; set; }
    public double Lon { get; set; }
    public required string Description { get; set; }
    public required string Policy { get; set; }
    public required string DetailAddress { get; set; }
    public required string Province { get; set; }
    public required string FullName { get; set; }
    public required string Email { get; set; }
    public required string PhoneNumber { get; set; }
    public required string CitizenId { get; set; }
    public string? FacebookUrl { get; set; }
    public List<IFormFile> FacilityImages { get; set; } = [];
    public required IFormFile CitizenImageFront { get; set; }
    public required IFormFile CitizenImageBack { get; set; }
    public required IFormFile BankCardFront { get; set; }
    public required IFormFile BankCardBack { get; set; }
    public List<IFormFile> BusinessLicenseImages { get; set; } = [];
}
