namespace SharedKernel.Exceptions;

public class NotificationNotFoundException(string notificationId)
    : NotFoundException($"The notification with the identifier {notificationId} was not found.")
{
}
