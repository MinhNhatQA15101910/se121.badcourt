using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using OrderService.Core.Domain.Repositories;
using SharedKernel.Params;

namespace OrderService.Infrastructure.ExternalServices.BackgroundServices;

public class DeletePendingOrdersBackgroundService(
    IServiceProvider serviceProvider
) : BackgroundService
{
    public bool HasPendingOrders { get; set; } = false;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        if (!HasPendingOrders) return;

        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = serviceProvider.CreateScope();
            var orderRepository = scope.ServiceProvider.GetRequiredService<IOrderRepository>();

            var currentTime = DateTime.UtcNow;

            Console.WriteLine("[DeletePendingOrdersBackgroundService] Running...");
            Console.WriteLine($"[DeletePendingOrdersBackgroundService] Current time: {currentTime}");

            var pendingOrders = await orderRepository.GetAllOrdersAsync(new OrderParams
            {
                State = "Pending"
            }, stoppingToken);

            if (pendingOrders == null || !pendingOrders.Any())
            {
                Console.WriteLine("[DeletePendingOrdersBackgroundService] No pending orders found.");
                HasPendingOrders = false;
                return;
            }

            foreach (var order in pendingOrders)
            {
                if (currentTime.AddMinutes(-20) > order.CreatedAt)
                {
                    Console.WriteLine($"[DeletePendingOrdersBackgroundService] Deleting order {order.Id} due to timeout.");
                    orderRepository.RemoveOrder(order);
                }
            }

            await orderRepository.CompleteAsync(stoppingToken);

            await Task.Delay(TimeSpan.FromSeconds(1), stoppingToken);
        }
    }
}
