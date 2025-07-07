using AuthService.Core.Application.Commands;
using AuthService.Core.Domain.Enums;
using AuthService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class UnlockUserHandler(
    IUserRepository userRepository,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<UnlockUserCommand, bool>
{
    public async Task<bool> Handle(UnlockUserCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetUserByIdAsync(request.UserId, cancellationToken)
            ?? throw new UserNotFoundException(request.UserId);

        if (user.State == UserState.Active)
        {
            throw new BadRequestException("User is already active.");
        }

        user.State = UserState.Active;
        user.UpdatedAt = DateTime.UtcNow;

        if (!await userRepository.SaveChangesAsync(cancellationToken))
        {
            throw new BadRequestException("Failed to unlock user.");
        }

        var userUnlockedEvent = new UserUnlockedEvent(user.Id.ToString());
        await publishEndpoint.Publish(userUnlockedEvent, cancellationToken);

        return true;
    }
}
