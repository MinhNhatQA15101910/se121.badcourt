using Application.Commands.Users;
using Application.Interfaces;
using CloudinaryDotNet.Actions;
using Domain.Exceptions;
using Domain.Repositories;

namespace Application.Handlers.CommandHandlers.Users;

public class DeletePhotoHandler(
    IUnitOfWork unitOfWork,
    IFileService fileService
) : ICommandHandler<DeletePhotoCommand, bool>
{
    public async Task<bool> Handle(DeletePhotoCommand request, CancellationToken cancellationToken)
    {
        var user = await unitOfWork.UserRepository.GetUserByIdAsync(request.UserId)
            ?? throw new UserNotFoundException(request.UserId);

        var photo = user.Photos.FirstOrDefault(p => p.Id == request.PhotoId);

        if (photo == null || photo.IsMain) throw new BadRequestException("This photo cannot be deleted");

        if (photo.PublicId != null)
        {
            var result = await fileService.DeleteFileAsync(photo.PublicId, ResourceType.Image);
            if (result.Error != null) throw new BadRequestException(result.Error.Message);
        }

        user.Photos.Remove(photo);

        if (await unitOfWork.Complete()) return true;

        throw new BadRequestException("Problem deleting photo");
    }
}
