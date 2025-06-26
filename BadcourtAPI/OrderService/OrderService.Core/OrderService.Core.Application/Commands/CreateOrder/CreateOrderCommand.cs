using SharedKernel.DTOs;

namespace OrderService.Core.Application.Commands.CreateOrder;

public record CreateOrderCommand(CreateOrderDto CreateOrderDto) : ICommand<OrderIntentDto>;
