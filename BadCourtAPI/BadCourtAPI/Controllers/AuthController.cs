using BadCourtAPI.Dtos.Auth;
using BadCourtAPI.Dtos.Users;
using BadCourtAPI.Features.Commands.Auth;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BadCourtAPI.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController(
    IMediator mediator
) : ControllerBase
{
    [HttpPost("login")]
    public async Task<ActionResult<UserDto>> Login(LoginDto loginDto)
    {
        var userDto = await mediator.Send(new LoginUserCommand(loginDto));
        return userDto;
    }
}
