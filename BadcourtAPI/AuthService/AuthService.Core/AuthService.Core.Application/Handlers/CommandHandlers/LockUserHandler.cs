using AuthService.Core.Application.Commands;
using AuthService.Core.Domain.Enums;
using AuthService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class LockUserHandler(
    IUserRepository userRepository,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<LockUserCommand, bool>
{
    public async Task<bool> Handle(LockUserCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetUserByIdAsync(request.UserId, cancellationToken)
            ?? throw new UserNotFoundException(request.UserId);

        if (user.State == UserState.Locked)
        {
            throw new BadRequestException("User is already locked.");
        }

        user.State = UserState.Locked;
        user.UpdatedAt = DateTime.UtcNow;

        if (!await userRepository.SaveChangesAsync(cancellationToken))
        {
            throw new BadRequestException("Failed to lock user.");
        }

        var userLockedEvent = new UserLockedEvent(user.Id.ToString());
        await publishEndpoint.Publish(userLockedEvent, cancellationToken);

        return true;
    }
}
