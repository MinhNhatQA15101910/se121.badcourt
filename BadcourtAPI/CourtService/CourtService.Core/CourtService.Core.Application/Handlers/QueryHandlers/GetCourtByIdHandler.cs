using AutoMapper;
using CourtService.Core.Application.Queries;
using CourtService.Core.Domain.Repositories;
using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Handlers.QueryHandlers;

public class GetCourtByIdHandler(
    ICourtRepository courtRepository,
    IMapper mapper
) : IQueryHandler<GetCourtByIdQuery, CourtDto>
{
    public async Task<CourtDto> Handle(GetCourtByIdQuery request, CancellationToken cancellationToken)
    {
        var court = await courtRepository.GetCourtByIdAsync(request.Id, cancellationToken)
            ?? throw new CourtNotFoundException(request.Id);

        return mapper.Map<CourtDto>(court);
    }

    // public async Task<CourtDto> Handle(GetCourtByIdQuery request, CancellationToken cancellationToken)
    // {
    //     var cacheKey = $"courts/{request.Id}";
    //     CourtDto? courtDto;

    //     var cachedData = await cache.GetStringAsync(cacheKey, token: cancellationToken);
    //     if (!string.IsNullOrEmpty(cachedData))
    //     {
    //         courtDto = JsonConvert.DeserializeObject<CourtDto>(cachedData) ?? new CourtDto();
    //     }
    //     else
    //     {
    //         var court = await courtRepository.GetCourtByIdAsync(request.Id, cancellationToken)
    //             ?? throw new CourtNotFoundException(request.Id);

    //         courtDto = mapper.Map<CourtDto>(court);

    //         var serializedData = JsonConvert.SerializeObject(courtDto);
    //         await cache.SetStringAsync(cacheKey, serializedData, new DistributedCacheEntryOptions
    //         {
    //             SlidingExpiration = TimeSpan.FromMinutes(5)
    //         }, token: cancellationToken);
    //     }

    //     return courtDto;
    // }
}
