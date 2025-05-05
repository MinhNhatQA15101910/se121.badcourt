using EmailService.Services;
using MassTransit;
using SharedKernel.Events;

namespace EmailService.Consumers;

public class SignupValidatedConsumer(IEmailService emailService) : IConsumer<SignupValidatedEvent>
{
    public async Task Consume(ConsumeContext<SignupValidatedEvent> context)
    {
        var displayName = context.Message.Username;
        var email = context.Message.Email;
        var pincode = context.Message.Pincode;
        var subject = "ACCOUNT VERIFICATION CODE";
        var message = await File.ReadAllTextAsync("Assets/EmailContent.html");
        message = message.Replace("{{PINCODE}}", pincode);

        await emailService.SendEmailAsync(displayName, email, subject, message);
    }
}
