using AuthService.Core.Application.Interfaces;
using AuthService.Core.Application.Notifications;
using MediatR;

namespace AuthService.Core.Application.Handlers.NotificationHandlers;

public class EmailValidatedEmailHandler(IEmailService emailService) : INotificationHandler<EmailValidatedNotification>
{
    public async Task Handle(EmailValidatedNotification notification, CancellationToken cancellationToken)
    {
        var displayName = notification.Email;
        var email = notification.Email;
        var subject = "ACCOUNT VERIFICATION CODE";
        var message = await File.ReadAllTextAsync("../AuthService.Core/AuthService.Core.Application/Assets/EmailContent.html", cancellationToken);
        message = message.Replace("{{PINCODE}}", notification.Pincode);

        await emailService.SendEmailAsync(displayName, email, subject, message);
    }
}
