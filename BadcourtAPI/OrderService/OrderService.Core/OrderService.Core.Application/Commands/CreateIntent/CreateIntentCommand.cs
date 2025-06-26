using Stripe;

namespace OrderService.Core.Application.Commands.CreateIntent;

public record CreateIntentCommand(CreateIntentDto CreateIntentDto) : ICommand<PaymentIntent>;
