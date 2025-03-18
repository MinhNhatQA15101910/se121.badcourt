using Application.Interfaces;
using Application.Notifications.Auth;
using MediatR;

namespace Application.Handlers.NotificationHandlers.Auth;

public class SignupValidatedEmailHandler(IEmailService emailService) : INotificationHandler<SignupValidatedNotification>
{
    public async Task Handle(SignupValidatedNotification notification, CancellationToken cancellationToken)
    {
        var displayName = notification.Username;
        var email = notification.Email;
        var pincode = notification.Pincode;
        var subject = "ACCOUNT VERIFICATION CODE";
        var message = await File.ReadAllTextAsync("../Core/Application/Assets/EmailContent.html", cancellationToken);
        message = message.Replace("{{PINCODE}}", pincode);

        await emailService.SendEmailAsync(displayName, email, subject, message);
    }
}
