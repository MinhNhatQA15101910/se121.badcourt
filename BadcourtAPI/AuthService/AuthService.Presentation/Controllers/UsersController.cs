using AuthService.Core.Application.Commands;
using AuthService.Core.Application.DTOs;
using AuthService.Core.Application.Queries;
using AuthService.Presentation.Extensions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AuthService.Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class UsersController(IMediator mediator) : ControllerBase
{
    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<UserDto>> GetCurrentUser()
    {
        var userDto = await mediator.Send(new GetCurrentUserQuery());
        return Ok(userDto);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<UserDto>> GetUser(Guid id)
    {
        var userDto = await mediator.Send(new GetUserByIdQuery(id));
        return Ok(userDto);
    }

    [HttpPatch("change-password")]
    [Authorize]
    public async Task<ActionResult> ChangePassword(ChangePasswordDto changePasswordDto)
    {
        await mediator.Send(new ChangePasswordCommand(changePasswordDto));

        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserDto>>> GetUsers([FromQuery] UserParams userParams)
    {
        var users = await mediator.Send(new GetUsersQuery(userParams));

        Response.AddPaginationHeader(users);

        return Ok(users);
    }

    [HttpPost("add-photo")]
    [Authorize]
    public async Task<ActionResult<PhotoDto>> AddPhoto(IFormFile file)
    {
        var photo = await mediator.Send(new AddPhotoCommand(User.GetUserId(), file));
        return CreatedAtAction(
            nameof(GetUser),
            new { id = User.GetUserId() },
            photo
        );
    }

    [HttpPut("set-main-photo/{photoId}")]
    [Authorize]
    public async Task<ActionResult> SetMainPhoto(Guid photoId)
    {
        await mediator.Send(new SetMainPhotoCommand(User.GetUserId(), photoId));
        return NoContent();
    }

    [HttpDelete("delete-photo/{photoId}")]
    [Authorize]
    public async Task<IActionResult> DeletePhoto(Guid photoId)
    {
        await mediator.Send(new DeletePhotoCommand(User.GetUserId(), photoId));
        return Ok();
    }

    [HttpGet("admin")]
    [Authorize]
    public async Task<ActionResult<UserBriefDto>> GetAdminBriefInfo()
    {
        var query = new GetAdminBriefInfoQuery();
        var user = await mediator.Send(query);
        return Ok(user);
    }

    [HttpPatch("lock/{userId}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> LockUser(Guid userId)
    {
        var command = new LockUserCommand(userId);
        await mediator.Send(command);

        return NoContent();
    }

    [HttpPatch("unlock/{userId}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UnlockUser(Guid userId)
    {
        var command = new UnlockUserCommand(userId);
        await mediator.Send(command);

        return NoContent();
    }
}
