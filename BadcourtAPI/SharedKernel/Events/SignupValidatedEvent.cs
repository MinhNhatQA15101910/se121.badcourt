namespace SharedKernel.Events;

public record SignupValidatedEvent(string Username, string Email, string Pincode);
