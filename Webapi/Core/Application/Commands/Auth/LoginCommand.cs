using Application.DTOs.Auth;
using SharedKernel.DTOs;

namespace Application.Commands.Auth;

public record LoginCommand(LoginDto LoginDto) : ICommand<UserDto>;
