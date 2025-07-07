using EmailService.Services;
using MassTransit;
using SharedKernel.Events;

namespace EmailService.Consumers;

public class EmailValidatedConsumer(IEmailService emailService) : IConsumer<EmailValidatedEvent>
{
    public async Task Consume(ConsumeContext<EmailValidatedEvent> context)
    {
        var displayName = context.Message.Email;
        var email = context.Message.Email;
        var subject = "ACCOUNT VERIFICATION CODE";
        var message = await File.ReadAllTextAsync("Assets/PincodeVerification.html");
        message = message.Replace("{{PINCODE}}", context.Message.Pincode);

        await emailService.SendEmailAsync(displayName, email, subject, message);
    }
}
