using SharedKernel.DTOs;

namespace OrderService.Core.Application.Queries.GetOrderById;

public record GetOrderByIdQuery(Guid Id) : IQuery<OrderDto>;
