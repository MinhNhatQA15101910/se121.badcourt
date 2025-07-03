
using OrderService.Core.Domain.Repositories;

namespace OrderService.Core.Application.Queries.GetTotalOrdersForAdmin;

public class GetTotalOrdersForAdminHandler(
    IOrderRepository orderRepository
) : IQueryHandler<GetTotalOrdersForAdminQuery, int>
{
    public Task<int> Handle(GetTotalOrdersForAdminQuery request, CancellationToken cancellationToken)
    {
        return orderRepository.GetTotalOrdersForAdminAsync(
            request.SummaryParams, cancellationToken
        );
    }
}
