using BadCourtAPI.Dtos.Auth;
using BadCourtAPI.Dtos.Users;

namespace BadCourtAPI.Features.Commands.Auth;

public record LoginUserCommand(LoginDto LoginDto) : ICommand<UserDto>;
