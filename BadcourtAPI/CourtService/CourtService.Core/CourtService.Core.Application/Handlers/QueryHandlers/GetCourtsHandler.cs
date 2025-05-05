using CourtService.Core.Application.Queries;
using CourtService.Core.Domain.Repositories;
using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Handlers.QueryHandlers;

public class GetCourtsHandler(
    ICourtRepository courtRepository
) : IQueryHandler<GetCourtsQuery, PagedList<CourtDto>>
{
    public async Task<PagedList<CourtDto>> Handle(GetCourtsQuery request, CancellationToken cancellationToken)
    {
        return await courtRepository.GetCourtsAsync(request.CourtParams, cancellationToken);
    }

    // public async Task<PagedList<CourtDto>> Handle(GetCourtsQuery request, CancellationToken cancellationToken)
    // {
    //     var cacheKey = GetCacheKey(request);
    //     PagedList<CourtDto> courts;

    //     var cachedData = await cache.GetStringAsync(cacheKey, cancellationToken);
    //     if (!string.IsNullOrEmpty(cachedData))
    //     {
    //         var settings = new JsonSerializerSettings();
    //         settings.Converters.Add(new PagedListConverter<CourtDto>());

    //         courts = JsonConvert.DeserializeObject<PagedList<CourtDto>>(cachedData, settings)
    //             ?? throw new BadRequestException($"Failed to deserialize cached data: {cacheKey}");
    //     }
    //     else
    //     {
    //         courts = await courtRepository.GetCourtsAsync(request.CourtParams, cancellationToken);
    //         var serializedData = JsonConvert.SerializeObject(courts, Formatting.Indented);
    //         await cache.SetStringAsync(cacheKey, serializedData, new DistributedCacheEntryOptions
    //         {
    //             SlidingExpiration = TimeSpan.FromMinutes(5)
    //         }, cancellationToken);
    //     }

    //     return courts;
    // }

    private static string GetCacheKey(GetCourtsQuery request)
    {
        var cacheKey = "courts";
        cacheKey += $"?pageNumber={request.CourtParams.PageNumber}";
        cacheKey += $"&pageSize={request.CourtParams.PageSize}";
        if (!string.IsNullOrEmpty(request.CourtParams.FacilityId))
        {
            cacheKey += $"&facilityId={request.CourtParams.FacilityId}";
        }
        cacheKey += $"&orderBy={request.CourtParams.OrderBy}";
        cacheKey += $"&sortBy={request.CourtParams.SortBy}";

        return cacheKey;
    }
}
