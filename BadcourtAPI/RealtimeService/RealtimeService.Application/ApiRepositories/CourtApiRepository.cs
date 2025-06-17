using System.Net.Http.Json;
using Microsoft.Extensions.Options;
using SharedKernel.DTOs;

namespace RealtimeService.Application.ApiRepositories;

public class CourtApiRepository(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : ICourtApiRepository
{
    public async Task<CourtDto?> GetCourtByIdAsync(string courtId)
    {
        var courtApiEndpoint = config.Value.CourtsApi;
        return await client.GetFromJsonAsync<CourtDto>($"{courtApiEndpoint}/{courtId}");
    }
}
