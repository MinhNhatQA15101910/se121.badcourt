using AuthService.Core.Application.Interfaces;
using AuthService.Core.Application.Notifications;
using MediatR;

namespace AuthService.Core.Application.Handlers.NotificationHandlers;

public class SignupValidatedEmailHandler(IEmailService emailService) : INotificationHandler<SignupValidatedNotification>
{
    public async Task Handle(SignupValidatedNotification notification, CancellationToken cancellationToken)
    {
        var displayName = notification.Username;
        var email = notification.Email;
        var pincode = notification.Pincode;
        var subject = "ACCOUNT VERIFICATION CODE";
        var message = await File.ReadAllTextAsync("../AuthService.Core/AuthService.Core.Application/Assets/EmailContent.html", cancellationToken);
        message = message.Replace("{{PINCODE}}", pincode);

        await emailService.SendEmailAsync(displayName, email, subject, message);
    }
}
