using Application.Commands.Auth;
using Application.DTOs.Auth;
using Domain.Enums;
using Domain.Exceptions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Presentation.Extensions;
using SharedKernel.DTOs;

namespace Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController(IMediator mediator) : ControllerBase
{
    [HttpPost("login")]
    public async Task<ActionResult<UserDto>> Login(LoginDto loginDto)
    {
        var user = await mediator.Send(new LoginCommand(loginDto));
        return Ok(user);
    }

    [HttpPost("validate-signup")]
    public async Task<ActionResult<UserDto>> ValidateSignup(ValidateSignupDto validateSignupDto)
    {
        var token = await mediator.Send(new ValidateSignupCommand(validateSignupDto));
        return Ok(new { token });
    }

    [HttpPost("email-exists")]
    public async Task<ActionResult<object>> EmailExists(ValidateEmailDto validateEmailDto)
    {
        var exists = await mediator.Send(new ValidateEmailCommand(validateEmailDto));
        if (exists is bool)
        {
            return exists;
        }

        return Ok(new { token = exists });
    }

    [HttpPost("verify-pincode")]
    [Authorize]
    public async Task<ActionResult<object>> VerifyPincode(VerifyPincodeDto verifyPincodeDto)
    {
        // Get email
        var email = User.GetEmail()
            ?? throw new UnauthorizedException("Email not found in claims");

        var action = User.GetAction();
        if (action == PincodeAction.None)
        {
            throw new UnauthorizedException("Invalid action");
        }

        verifyPincodeDto.Email = email;
        verifyPincodeDto.Action = action;

        var result = await mediator.Send(new VerifyPincodeCommand(verifyPincodeDto));
        if (result is string)
        {
            return Ok(new { token = result });
        }

        return Ok(result);
    }

    [HttpPatch("reset-password")]
    [Authorize]
    public async Task<ActionResult> ResetPassword(ResetPasswordDto resetPasswordDto)
    {
        // Get userId
        var userId = User.GetUserId();

        resetPasswordDto.UserId = userId;

        await mediator.Send(new ResetPasswordCommand(resetPasswordDto));

        return NoContent();
    }
}
