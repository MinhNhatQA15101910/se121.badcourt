using AutoMapper;
using OrderService.Core.Domain.Repositories;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace OrderService.Core.Application.Queries.GetOrderById;

public class GetOrderByIdHandler(
    IOrderRepository orderRepository,
    IMapper mapper
) : IQueryHandler<GetOrderByIdQuery, OrderDto>
{
    public async Task<OrderDto> Handle(GetOrderByIdQuery request, CancellationToken cancellationToken)
    {
        var order = await orderRepository.GetOrderByIdAsync(request.Id, cancellationToken)
            ?? throw new OrderNotFoundException(request.Id);

        return mapper.Map<OrderDto>(order);
    }
}
