using MediatR;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Queries.GetRatingById;
using SharedKernel.DTOs;

namespace OrderService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class RatingsController(IMediator mediator) : ControllerBase
{
    [HttpGet("{ratingId:guid}")]
    public async Task<ActionResult<RatingDto>> GetRatingById(Guid ratingId)
    {
        return await mediator.Send(new GetRatingByIdQuery(ratingId));
    }
}
