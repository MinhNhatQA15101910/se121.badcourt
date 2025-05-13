using OrderService.Core.Application.Commands.CreateOrder;

namespace OrderService.Core.Application.Commands.CheckConflict;

public record CheckConflictCommand(CreateOrderDto CheckConflictDto) : ICommand<bool>;
