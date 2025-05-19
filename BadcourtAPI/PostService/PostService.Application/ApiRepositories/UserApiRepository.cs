using System.Net.Http.Json;
using Microsoft.Extensions.Options;
using SharedKernel.DTOs;

namespace PostService.Application.ApiRepositories;

public class UserApiRepository(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : IUserApiRepository
{
    public async Task<UserDto?> GetUserByIdAsync(Guid userId)
    {
        var userApiEndpoint = config.Value.UsersApi;
        return await client.GetFromJsonAsync<UserDto>($"{userApiEndpoint}/{userId}");
    }
}
