using FacilityService.Core.Application.Notifications;
using MediatR;
using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;

namespace FacilityService.Core.Application.Handlers.NotificationHandlers;

public class FacilityUpdatedHandler(IDistributedCache cache) : INotificationHandler<FacilityUpdatedNotification>
{
    public async Task Handle(FacilityUpdatedNotification notification, CancellationToken cancellationToken)
    {
        var cacheKey = $"facilities/{notification.UpdatedFacility.Id}";
        var serializedData = JsonConvert.SerializeObject(notification.UpdatedFacility);
        await cache.SetStringAsync(cacheKey, serializedData, new DistributedCacheEntryOptions
        {
            SlidingExpiration = TimeSpan.FromMinutes(5)
        }, token: cancellationToken);
    }
}
