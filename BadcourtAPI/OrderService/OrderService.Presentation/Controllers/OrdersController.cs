using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Commands.CreateOrder;
using OrderService.Core.Application.Queries.GetOrderById;
using OrderService.Core.Application.Queries.GetOrders;
using OrderService.Presentation.Extensions;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace OrderService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class OrdersController(IMediator mediator) : ControllerBase
{
    [HttpGet("{id}")]
    [Authorize]
    public async Task<ActionResult<OrderDto>> GetOrderById(Guid id)
    {
        return await mediator.Send(new GetOrderByIdQuery(id));
    }

    [HttpGet]
    [Authorize]
    public async Task<ActionResult<PagedList<OrderDto>>> GetOrders([FromQuery] OrderParams orderParams)
    {
        var orders = await mediator.Send(new GetOrdersQuery(orderParams));

        Response.AddPaginationHeader(orders);

        return orders;
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<OrderDto>> CreateOrder(CreateOrderDto createOrderDto)
    {
        var order = await mediator.Send(new CreateOrderCommand(createOrderDto));
        return CreatedAtAction(nameof(GetOrderById), new { id = order.Id }, order);
    }
}
