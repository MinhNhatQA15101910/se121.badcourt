using System.Net.Http.Json;
using Microsoft.Extensions.Options;
using OrderService.Infrastructure.Configuration;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.ApiRepository;

public class UserApiRepository(
    IOptions<ApiEndpoints> config,
    HttpClient client
) : IUserApiRepository
{
    public Task<UserDto?> GetUserByIdAsync(string userId, CancellationToken cancellationToken = default)
    {
        var usersApiEndpoint = config.Value.UsersApi;
        return client.GetFromJsonAsync<UserDto>($"{usersApiEndpoint}/{userId}", cancellationToken);
    }
}
