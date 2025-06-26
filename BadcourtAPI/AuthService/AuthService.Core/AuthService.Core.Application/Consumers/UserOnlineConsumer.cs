using AuthService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Consumers;

public class UserOnlineConsumer(IUserRepository userRepository) : IConsumer<UserOnlineEvent>
{
    public async Task Consume(ConsumeContext<UserOnlineEvent> context)
    {
        _ = Guid.TryParse(context.Message.UserId, out var userId)
            ? context.Message.UserId
            : throw new ArgumentException("Invalid UserId format", nameof(context.Message.UserId));

        var user = await userRepository.GetUserByIdAsync(userId)
            ?? throw new UserNotFoundException(userId);

        user.LastOnlineAt = null;

        if (!await userRepository.SaveChangesAsync())
        {
            throw new Exception($"Failed to update user {userId} online status.");
        }

        Console.WriteLine($"User {userId} marked as online.");
    }
}
