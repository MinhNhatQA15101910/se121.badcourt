using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Commands.CancelOrder;
using OrderService.Core.Application.Commands.CheckConflict;
using OrderService.Core.Application.Commands.CreateOrder;
using OrderService.Core.Application.Commands.CreateRating;
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
    public async Task<ActionResult<OrderIntentDto>> CreateOrder(CreateOrderDto createOrderDto)
    {
        var orderIntent = await mediator.Send(new CreateOrderCommand(createOrderDto));
        return Ok(orderIntent);
    }

    [HttpPost("check-conflict")]
    [Authorize]
    public async Task<IActionResult> CheckConflict(CreateOrderDto checkConflictDto)
    {
        await mediator.Send(new CheckConflictCommand(checkConflictDto));
        return Ok();
    }

    [HttpPut("cancel/{id}")]
    [Authorize]
    public async Task<IActionResult> CancelOrder(Guid id)
    {
        await mediator.Send(new CancelOrderCommand(id));
        return NoContent();
    }

    [HttpPost("rate/{id}")]
    public async Task<ActionResult<RatingDto>> CreateRating(Guid id, CreateRatingDto createRatingDto)
    {
        var rating = await mediator.Send(new CreateRatingCommand(id, createRatingDto));
        return CreatedAtAction(nameof(GetOrderById), new { id }, rating);
    }
}
