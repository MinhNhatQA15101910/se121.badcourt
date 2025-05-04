using Microsoft.Extensions.Configuration;

namespace CourtService.Core.Application.ApiRepositories;

public class ApiEndpoints(IConfiguration configuration)
{
    private const string Facilities = "/facilities";

    public string GetFacilitiesApi()
    {
        return configuration["ApiEndpoints:FacilitiesApi"] + Facilities;
    }
}
