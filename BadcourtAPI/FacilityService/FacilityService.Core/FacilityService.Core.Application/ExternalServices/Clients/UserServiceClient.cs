using System.Net.Http.Json;
using FacilityService.Core.Application.ExternalServices.Interfaces;
using Microsoft.Extensions.Options;
using SharedKernel.DTOs;

namespace FacilityService.Core.Application.ExternalServices.Clients;

public class UserServiceClient(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : IUserServiceClient
{
    public async Task<UserDto?> GetUserByIdAsync(Guid userId)
    {
        var userApiEndpoint = config.Value.UsersApi;
        return await client.GetFromJsonAsync<UserDto>($"{userApiEndpoint}/{userId}");
    }
}
