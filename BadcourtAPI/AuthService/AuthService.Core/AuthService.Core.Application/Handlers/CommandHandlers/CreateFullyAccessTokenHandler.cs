using AuthService.Core.Application.Commands;
using AuthService.Core.Application.Interfaces;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class CreateFullyAccessTokenHandler(
    ITokenService tokenService
) : ICommandHandler<CreateFullyAccessTokenCommand, string>
{
    public async Task<string> Handle(CreateFullyAccessTokenCommand request, CancellationToken cancellationToken)
    {
        return await tokenService.CreateFullyAccessTokenAsync();
    }
}
