using MediatR;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Queries.GetRatingById;
using OrderService.Core.Application.Queries.GetRatings;
using OrderService.Presentation.Extensions;
using SharedKernel.DTOs;
using SharedKernel.Params;

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

    [HttpGet]
    public async Task<ActionResult<IEnumerable<RatingDto>>> GetRatings([FromQuery] RatingParams ratingParams)
    {
        var ratings = await mediator.Send(new GetRatingsQuery(ratingParams));

        Response.AddPaginationHeader(ratings);

        return Ok(ratings);
    }
}
