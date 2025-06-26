using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetOrderDetails;

public record GetOrderDetailsQuery(OrderParams OrderParams) : IQuery<PagedList<OrderDto>>;
