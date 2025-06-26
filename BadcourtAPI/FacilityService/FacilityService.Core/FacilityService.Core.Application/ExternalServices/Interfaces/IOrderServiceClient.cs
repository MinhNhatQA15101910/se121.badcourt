using SharedKernel.DTOs;
using SharedKernel.Params;

namespace FacilityService.Core.Application.ExternalServices.Interfaces;

public interface IOrderServiceClient
{
    Task<IEnumerable<OrderDto>?> GetOrdersAsync(OrderParams orderParams);
}
