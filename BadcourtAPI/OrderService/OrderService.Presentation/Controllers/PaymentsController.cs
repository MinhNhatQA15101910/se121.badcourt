using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Commands.CreateIntent;

namespace OrderService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class PaymentsController(IMediator mediator) : ControllerBase
{
    [Authorize]
    [HttpPost("create-intent")]
    public async Task<IActionResult> CreateIntent(CreateIntentDto createIntentDto)
    {
        var intent = await mediator.Send(new CreateIntentCommand(createIntentDto));
        return Ok(new { clientSecret = intent.ClientSecret });
    }
}
