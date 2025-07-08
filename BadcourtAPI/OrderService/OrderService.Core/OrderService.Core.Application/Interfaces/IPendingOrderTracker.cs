namespace OrderService.Core.Application.Interfaces;

public interface IPendingOrderTracker
{
    bool HasPendingOrders { get; set; }
}
