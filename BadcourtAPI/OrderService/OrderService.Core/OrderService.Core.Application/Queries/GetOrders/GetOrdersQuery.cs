using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetOrders;

public record GetOrdersQuery(OrderParams OrderParams) : IQuery<PagedList<OrderDto>>;
