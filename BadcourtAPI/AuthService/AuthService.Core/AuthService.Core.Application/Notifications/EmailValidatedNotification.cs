using MediatR;

namespace AuthService.Core.Application.Notifications;

public record EmailValidatedNotification(string Email, string Pincode) : INotification;
