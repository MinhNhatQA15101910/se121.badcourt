using FacilityService.Core.Application.Queries;
using FacilityService.Core.Domain.Repositories;
using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.QueryHandlers;

public class GetFacilityProvincesHandler(
    IFacilityRepository facilityRepository,
    IDistributedCache cache
) : IQueryHandler<GetFacilityProvincesQuery, List<string>>
{
    public async Task<List<string>> Handle(GetFacilityProvincesQuery request, CancellationToken cancellationToken)
    {
        var cacheKey = "facilities/provinces";
        List<string> provinces;

        var cachedData = await cache.GetStringAsync(cacheKey, cancellationToken);
        if (!string.IsNullOrEmpty(cachedData))
        {
            provinces = JsonConvert.DeserializeObject<List<string>>(cachedData)
                ?? throw new BadRequestException($"Failed to deserialize cached data: {cacheKey}");
        }
        else
        {
            provinces = await facilityRepository.GetFacilityProvincesAsync(cancellationToken);
            var serializedData = JsonConvert.SerializeObject(provinces, Formatting.Indented);
            await cache.SetStringAsync(cacheKey, serializedData, new DistributedCacheEntryOptions
            {
                SlidingExpiration = TimeSpan.FromMinutes(5)
            }, cancellationToken);
        }

        return provinces;
    }
}
