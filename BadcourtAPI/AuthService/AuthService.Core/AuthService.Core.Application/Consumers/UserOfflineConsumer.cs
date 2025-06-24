using AuthService.Core.Domain.Repositories;
using MassTransit;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Consumers;

public class UserOfflineConsumer(IUserRepository userRepository) : IConsumer<UserOfflineEvent>
{
    public async Task Consume(ConsumeContext<UserOfflineEvent> context)
    {
        _ = Guid.TryParse(context.Message.UserId, out var userId)
            ? context.Message.UserId
            : throw new ArgumentException("Invalid UserId format", nameof(context.Message.UserId));

        var user = await userRepository.GetUserByIdAsync(userId)
            ?? throw new UserNotFoundException(userId);

        user.LastOnlineAt = DateTime.UtcNow;

        if (!await userRepository.SaveChangesAsync())
        {
            throw new Exception($"Failed to update user {userId} online status.");
        }

        Console.WriteLine($"User {userId} marked as offline.");
    }
}
