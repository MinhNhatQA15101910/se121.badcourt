using SharedKernel.DTOs;
using SharedKernel.Params;

namespace CourtService.Core.Application.Interfaces.ServiceClients;

public interface IOrderServiceClient
{
    Task<IEnumerable<OrderDto>?> GetOrdersAsync(
        OrderParams orderParams, CancellationToken cancellationToken = default);
}
