namespace SharedKernel.Events;

public record UserLockedEvent(string UserId, string Username, string Email);
