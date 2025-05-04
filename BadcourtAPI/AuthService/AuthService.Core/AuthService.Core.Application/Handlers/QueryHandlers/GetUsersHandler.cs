using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetUsersHandler(
    IUserRepository userRepository
) : IRequestHandler<GetUsersQuery, PagedList<UserDto>>
{
    public async Task<PagedList<UserDto>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
    {
        return await userRepository.GetUsersAsync(request.UserParams);
    }

    // public async Task<PagedList<UserDto>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
    // {
    //     // Custom cache key
    //     var cacheKey = GetCacheKey(request);
    //     PagedList<UserDto> users;

    //     var cachedData = await cache.GetStringAsync(cacheKey, cancellationToken);
    //     if (!string.IsNullOrEmpty(cachedData))
    //     {
    //         var settings = new JsonSerializerSettings();
    //         settings.Converters.Add(new PagedListConverter<UserDto>());

    //         users = JsonConvert.DeserializeObject<PagedList<UserDto>>(cachedData, settings)
    //             ?? throw new BadRequestException($"Failed to deserialize cached data: {cacheKey}");
    //     }
    //     else
    //     {
    //         users = await userRepository.GetUsersAsync(request.UserParams);
    //         var serializedData = JsonConvert.SerializeObject(users);
    //         await cache.SetStringAsync(cacheKey, serializedData, new DistributedCacheEntryOptions
    //         {
    //             SlidingExpiration = TimeSpan.FromMinutes(5)
    //         }, cancellationToken);
    //     }

    //     return users;
    // }

    private static string GetCacheKey(GetUsersQuery request)
    {
        var cacheKey = "users";
        cacheKey += $"?pageNumber={request.UserParams.PageNumber}";
        cacheKey += $"&pageSize={request.UserParams.PageSize}";
        cacheKey += $"?currentUserId={request.UserParams.CurrentUserId}";
        if (!string.IsNullOrEmpty(request.UserParams.Username))
        {
            cacheKey += $"&username={request.UserParams.Username}";
        }
        if (!string.IsNullOrEmpty(request.UserParams.Email))
        {
            cacheKey += $"&email={request.UserParams.Email}";
        }
        cacheKey += $"&orderBy={request.UserParams.OrderBy}";
        cacheKey += $"&sortBy={request.UserParams.SortBy}";

        return cacheKey;
    }
}
