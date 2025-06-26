using FluentValidation;

namespace RealtimeService.Application.Commands.UpdateReadNotification;

public class UpdateReadNotificationValidator : AbstractValidator<UpdateReadNotificationCommand>
{
    public UpdateReadNotificationValidator()
    {
        RuleFor(x => x.NotificationId)
            .NotEmpty().WithMessage("Notification ID cannot be empty.")
            .NotNull().WithMessage("Notification ID cannot be null.");
    }
}
