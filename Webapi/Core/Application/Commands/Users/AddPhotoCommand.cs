using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;

namespace Application.Commands.Users;

public record AddPhotoCommand(Guid UserId, IFormFile File) : ICommand<PhotoDto>;
