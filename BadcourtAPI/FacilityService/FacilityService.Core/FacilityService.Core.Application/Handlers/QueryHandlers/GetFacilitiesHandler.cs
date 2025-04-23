using FacilityService.Core.Application.Queries;
using FacilityService.Core.Domain.Repositories;
using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.QueryHandlers;

public class GetFacilitiesHandler(
    IFacilityRepository facilityRepository,
    IDistributedCache cache
) : IQueryHandler<GetFacilitiesQuery, PagedList<FacilityDto>>
{
    public async Task<PagedList<FacilityDto>> Handle(GetFacilitiesQuery request, CancellationToken cancellationToken)
    {
        var cacheKey = GetCacheKey(request);
        PagedList<FacilityDto> facilities;

        var cachedData = await cache.GetStringAsync(cacheKey, cancellationToken);
        if (!string.IsNullOrEmpty(cachedData))
        {
            var settings = new JsonSerializerSettings();
            settings.Converters.Add(new PagedListConverter<FacilityDto>());

            facilities = JsonConvert.DeserializeObject<PagedList<FacilityDto>>(cachedData, settings)
                ?? throw new BadRequestException($"Failed to deserialize cached data: {cacheKey}");
        }
        else
        {
            facilities = await facilityRepository.GetFacilitiesAsync(request.FacilityParams, cancellationToken);
            var serializedData = JsonConvert.SerializeObject(facilities, Formatting.Indented);
            await cache.SetStringAsync(cacheKey, serializedData, new DistributedCacheEntryOptions
            {
                SlidingExpiration = TimeSpan.FromMinutes(5)
            }, cancellationToken);
        }

        return facilities;
    }

    private static string GetCacheKey(GetFacilitiesQuery request)
    {
        var cacheKey = "facilities";
        cacheKey += $"?pageNumber={request.FacilityParams.PageNumber}";
        cacheKey += $"&pageSize={request.FacilityParams.PageSize}";
        if (!string.IsNullOrEmpty(request.FacilityParams.UserId))
        {
            cacheKey += $"&userId={request.FacilityParams.UserId}";
        }
        if (!string.IsNullOrEmpty(request.FacilityParams.FacilityName))
        {
            cacheKey += $"&facilityName={request.FacilityParams.FacilityName}";
        }
        cacheKey += $"&lat={request.FacilityParams.Lat}";
        cacheKey += $"&lon={request.FacilityParams.Lon}";
        if (!string.IsNullOrEmpty(request.FacilityParams.Province))
        {
            cacheKey += $"&province={request.FacilityParams.Province}";
        }
        cacheKey += $"&minPrice={request.FacilityParams.MinPrice}";
        cacheKey += $"&maxPrice={request.FacilityParams.MaxPrice}";
        cacheKey += $"&orderBy={request.FacilityParams.OrderBy}";
        cacheKey += $"&sortBy={request.FacilityParams.SortBy}";

        return cacheKey;
    }
}
