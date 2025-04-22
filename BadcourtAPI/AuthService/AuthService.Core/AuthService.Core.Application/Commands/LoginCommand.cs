using AuthService.Core.Application.DTOs;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Commands;

public record LoginCommand(LoginDto LoginDto) : ICommand<UserDto>;
