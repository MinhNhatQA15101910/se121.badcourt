using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Commands.CreateOrder;
using OrderService.Core.Application.Queries.GetOrderById;
using SharedKernel.DTOs;

namespace OrderService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class OrdersController(IMediator mediator) : ControllerBase
{
    [HttpGet("{id}")]
    public async Task<ActionResult<OrderDto>> GetOrderById(Guid id)
    {
        return await mediator.Send(new GetOrderByIdQuery(id));
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<OrderDto>> CreateOrder(CreateOrderDto createOrderDto)
    {
        var order = await mediator.Send(new CreateOrderCommand(createOrderDto));
        return CreatedAtAction(nameof(GetOrderById), new { id = order.Id }, order);
    }
}
