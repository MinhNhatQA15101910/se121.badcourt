using EmailService.Services;
using MassTransit;
using SharedKernel.Events;

namespace EmailService.Consumers;

public class UserLockedConsumer(IEmailService emailService) : IConsumer<UserLockedEvent>
{
    public async Task Consume(ConsumeContext<UserLockedEvent> context)
    {
        var displayName = context.Message.Username;
        var email = context.Message.Email;
        var subject = "[BadCourt] Account Locked Notification";
        var message = await File.ReadAllTextAsync("Assets/AccountLockedNotification.html");
        message = message.Replace("{{UserName}}", context.Message.Username);

        await emailService.SendEmailAsync(displayName, email, subject, message);
    }
}
