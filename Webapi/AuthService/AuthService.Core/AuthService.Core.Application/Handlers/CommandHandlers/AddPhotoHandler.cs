using AuthService.Core.Application.Commands;
using AuthService.Core.Application.Interfaces;
using AuthService.Core.Domain.Entities;
using AuthService.Core.Domain.Exceptions;
using AuthService.Core.Domain.Repositories;
using AutoMapper;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class AddPhotoHandler(
    IUserRepository userRepository,
    IFileService fileService,
    IMapper mapper
) : ICommandHandler<AddPhotoCommand, PhotoDto>
{
    public async Task<PhotoDto> Handle(AddPhotoCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetUserByIdAsync(request.UserId)
            ?? throw new UserNotFoundException(request.UserId);

        var result = await fileService.UploadPhotoAsync($"users/{request.UserId}", request.File);
        if (result.Error != null) throw new BadRequestException(result.Error.Message);

        var photo = new UserPhoto
        {
            Url = result.SecureUrl.AbsoluteUri,
            PublicId = result.PublicId,
            IsMain = user.Photos.Count == 0
        };
        user.Photos.Add(photo);

        if (await userRepository.SaveChangesAsync())
        {
            return mapper.Map<PhotoDto>(photo);
        }

        throw new BadRequestException("Problem adding photo");
    }
}
