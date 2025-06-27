using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using OrderService.Core.Domain.Enums;
using OrderService.Core.Domain.Repositories;
using SharedKernel.Params;

namespace OrderService.Infrastructure.ExternalServices.BackgroundServices;

public class UpdateOrderStateBackgroundService(IServiceProvider serviceProvider) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = serviceProvider.CreateScope();
            var orderRepository = scope.ServiceProvider.GetRequiredService<IOrderRepository>();

            var currentTime = DateTime.UtcNow;

            Console.WriteLine("[UpdateOrderStateBackgroundService] Running...");
            Console.WriteLine($"[UpdateOrderStateBackgroundService] Current time: {currentTime}");

            var notPlayOrders = await orderRepository.GetAllOrdersAsync(new OrderParams
            {
                State = "NotPlay"
            }, stoppingToken);
            foreach (var order in notPlayOrders)
            {
                if (currentTime > order.DateTimePeriod.HourFrom && currentTime < order.DateTimePeriod.HourTo)
                {
                    order.State = OrderState.Playing;
                }
            }

            var playingOrders = await orderRepository.GetAllOrdersAsync(new OrderParams
            {
                State = "Playing"
            }, stoppingToken);
            foreach (var order in playingOrders)
            {
                if (currentTime > order.DateTimePeriod.HourTo)
                {
                    order.State = OrderState.Played;
                }
            }

            await orderRepository.CompleteAsync(stoppingToken);

            await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
        }
    }
}
