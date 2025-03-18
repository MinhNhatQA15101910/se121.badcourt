using Application.Interfaces;
using Configuration;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;

namespace Services;

public class EmailService(IOptions<EmailSenderSettings> config) : IEmailService
{
    public async Task SendEmailAsync(string displayName, string email, string subject, string content)
    {
        var emailMessage = CreateMailMessage(displayName, email, subject, content);

        await SendAsync(emailMessage);
    }

    private MimeMessage CreateMailMessage(string displayName, string email, string subject, string content)
    {
        var emailMessage = new MimeMessage();
        emailMessage.From.Add(new MailboxAddress(config.Value.DisplayName, config.Value.From));
        emailMessage.To.Add(new MailboxAddress(displayName, email));
        emailMessage.Subject = subject;
        emailMessage.Body = new TextPart(MimeKit.Text.TextFormat.Html)
        {
            Text = content
        };

        return emailMessage;
    }

    private async Task SendAsync(MimeMessage mailMessage)
    {
        using var smtp = new SmtpClient();

        await smtp.ConnectAsync(config.Value.SmtpServer, config.Value.Port, SecureSocketOptions.StartTls);

        // Note: only needed if the SMTP server requires authentication
        await smtp.AuthenticateAsync(config.Value.UserName, config.Value.Password);

        var result = await smtp.SendAsync(mailMessage);
        await smtp.DisconnectAsync(true);
    }
}
