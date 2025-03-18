using MediatR;

namespace Application.Notifications.Auth;

public record SignupValidatedNotification(string Username, string Email, string Pincode) : INotification;
