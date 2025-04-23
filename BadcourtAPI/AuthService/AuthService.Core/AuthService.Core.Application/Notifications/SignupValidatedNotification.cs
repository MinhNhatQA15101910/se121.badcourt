using MediatR;

namespace AuthService.Core.Application.Notifications;

public record SignupValidatedNotification(string Username, string Email, string Pincode) : INotification;
