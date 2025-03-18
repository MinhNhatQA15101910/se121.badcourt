using MediatR;

namespace Application.Notifications.Auth;

public record EmailValidatedNotification(string Email, string Pincode) : INotification;
