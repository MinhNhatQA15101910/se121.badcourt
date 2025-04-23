using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Commands;

public record AddPhotoCommand(Guid UserId, IFormFile File) : ICommand<PhotoDto>;
