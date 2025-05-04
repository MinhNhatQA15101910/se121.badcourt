using System.Text.Json;
using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;
using AutoMapper;
using Microsoft.Extensions.Caching.Distributed;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetUserByIdHandler(
    IUserRepository userRepository,
    IMapper mapper
) : IQueryHandler<GetUserByIdQuery, UserDto>
{
    public async Task<UserDto> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetUserByIdAsync(request.Id, cancellationToken)
            ?? throw new UserNotFoundException(request.Id);

        return mapper.Map<UserDto>(user);
    }

    // public async Task<UserDto> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
    // {
    //     var cacheKey = $"users/{request.Id}";
    //     UserDto? userDto;

    //     var cachedData = await cache.GetStringAsync(cacheKey, token: cancellationToken);
    //     if (!string.IsNullOrEmpty(cachedData))
    //     {
    //         userDto = JsonSerializer.Deserialize<UserDto>(cachedData) ?? new UserDto();
    //     }
    //     else
    //     {
    //         var user = await userRepository.GetUserByIdAsync(request.Id) 
    //             ?? throw new UserNotFoundException(request.Id);

    //         userDto = mapper.Map<UserDto>(user);

    //         var serializedData = JsonSerializer.Serialize(userDto);
    //         await cache.SetStringAsync(cacheKey, serializedData, new DistributedCacheEntryOptions
    //         {
    //             SlidingExpiration = TimeSpan.FromMinutes(5)
    //         }, token: cancellationToken);
    //     }

    //     return userDto;
    // }
}
