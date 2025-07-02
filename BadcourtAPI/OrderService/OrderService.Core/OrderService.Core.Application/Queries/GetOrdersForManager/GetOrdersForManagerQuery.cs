using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Core.Application.Queries.GetOrdersForManager;

public record GetOrdersForManagerQuery(
    ManagerDashboardOrderParams OrderParams
) : IQuery<PagedList<OrderDto>>;
