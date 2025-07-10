using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using OrderService.Core.Application.Interfaces;
using OrderService.Core.Domain.Repositories;
using SharedKernel.Params;

namespace OrderService.Infrastructure.ExternalServices.BackgroundServices;

public class DeletePendingOrdersBackgroundService(
    IServiceProvider serviceProvider
) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {

        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = serviceProvider.CreateScope();

            var pendingOrderTracker = scope.ServiceProvider.GetRequiredService<IPendingOrderTracker>();
            if (!pendingOrderTracker.HasPendingOrders)
            {
                Console.WriteLine("[DeletePendingOrdersBackgroundService] No pending orders to process.");
                continue;
            }

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
                pendingOrderTracker.HasPendingOrders = false;
                return;
            }
            else
            {
                pendingOrderTracker.HasPendingOrders = true;
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

            await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
        }
    }
}
