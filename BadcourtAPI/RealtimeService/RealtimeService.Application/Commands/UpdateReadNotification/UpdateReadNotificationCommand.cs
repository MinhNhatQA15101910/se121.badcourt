namespace RealtimeService.Application.Commands.UpdateReadNotification;

public record UpdateReadNotificationCommand(string NotificationId) : ICommand<bool>;
