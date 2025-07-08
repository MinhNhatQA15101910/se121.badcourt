using OrderService.Core.Application.Interfaces;

namespace OrderService.Infrastructure.ExternalServices.Services;

public class PendingOrderTracker : IPendingOrderTracker
{
    public bool HasPendingOrders { get; set; } = true;
}
