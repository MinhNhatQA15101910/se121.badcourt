using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrderService.Core.Application.Commands.CreateIntent;
using Stripe;

namespace OrderService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class PaymentsController(
    IMediator mediator,
    IConfiguration config
) : ControllerBase
{
    [Authorize]
    [HttpPost("create-intent")]
    public async Task<IActionResult> CreateIntent(CreateIntentDto createIntentDto)
    {
        var intent = await mediator.Send(new CreateIntentCommand(createIntentDto));
        return Ok(new { clientSecret = intent.ClientSecret });
    }

    [HttpPost("webhook")]
    public async Task<IActionResult> StripeWebhook()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
        var webhookSecret = config["StripeSettings:WebhookSecret"];

        try
        {
            var stripeEvent = EventUtility.ConstructEvent(
                json,
                Request.Headers["Stripe-Signature"],
                webhookSecret
            );

            if (stripeEvent.Type == "payment_intent.succeeded")
            {
                var intent = stripeEvent.Data.Object as PaymentIntent;

                // ✅ Your logic here
            }

            return Ok();
        }
        catch (StripeException)
        {
            return BadRequest();
        }
    }
}
