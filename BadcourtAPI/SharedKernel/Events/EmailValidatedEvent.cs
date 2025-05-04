namespace SharedKernel.Events;

public record EmailValidatedEvent(string Email, string Pincode);
