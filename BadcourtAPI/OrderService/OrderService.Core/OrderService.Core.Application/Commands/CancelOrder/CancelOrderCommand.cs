namespace OrderService.Core.Application.Commands.CancelOrder;

public record CancelOrderCommand(Guid OrderId) : ICommand<bool>;
