using AuthService.Core.Application.Commands;
using AuthService.Core.Domain.Enums;
using AuthService.Core.Domain.Repositories;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class LockUserHandler(
    IUserRepository userRepository
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

        return true;
    }
}
