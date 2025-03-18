namespace Application.Interfaces;

public interface IEmailService
{
    Task SendEmailAsync(string displayName, string email, string subject, string content);
}
