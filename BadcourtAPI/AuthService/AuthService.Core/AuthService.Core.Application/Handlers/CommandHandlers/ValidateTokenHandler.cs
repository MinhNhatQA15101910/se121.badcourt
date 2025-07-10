using AuthService.Core.Application.Commands;
using AuthService.Core.Application.Extensions;
using AuthService.Core.Domain.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class ValidateTokenHandler(
    IHttpContextAccessor httpContextAccessor,
    UserManager<User> userManager
) : ICommandHandler<ValidateTokenCommand, bool>
{
    public async Task<bool> Handle(ValidateTokenCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        _ = await userManager.FindByIdAsync(userId.ToString())
            ?? throw new UserNotFoundException(userId);

        return true;
    }
}
