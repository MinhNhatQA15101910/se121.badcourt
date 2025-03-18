using Application.Commands.Users;
using Application.Interfaces;
using AutoMapper;
using Domain.Entities;
using Domain.Exceptions;
using Domain.Repositories;
using SharedKernel.DTOs;

namespace Application.Handlers.CommandHandlers.Users;

public class AddPhotoHandler(
    IUnitOfWork unitOfWork,
    IFileService fileService,
    IMapper mapper
) : ICommandHandler<AddPhotoCommand, PhotoDto>
{
    public async Task<PhotoDto> Handle(AddPhotoCommand request, CancellationToken cancellationToken)
    {
        var user = await unitOfWork.UserRepository.GetUserByIdAsync(request.UserId)
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

        if (await unitOfWork.Complete())
        {
            return mapper.Map<PhotoDto>(photo);
        }

        throw new BadRequestException("Problem adding photo");
    }
}
