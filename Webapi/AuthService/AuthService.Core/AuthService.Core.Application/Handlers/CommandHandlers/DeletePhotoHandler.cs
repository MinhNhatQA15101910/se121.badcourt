using AuthService.Core.Application.Commands;
using AuthService.Core.Application.Interfaces;
using AuthService.Core.Domain.Exceptions;
using AuthService.Core.Domain.Repositories;
using CloudinaryDotNet.Actions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class DeletePhotoHandler(
    IUserRepository userRepository,
    IFileService fileService
) : ICommandHandler<DeletePhotoCommand, bool>
{
    public async Task<bool> Handle(DeletePhotoCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetUserByIdAsync(request.UserId)
            ?? throw new UserNotFoundException(request.UserId);

        var photo = user.Photos.FirstOrDefault(p => p.Id == request.PhotoId);

        if (photo == null || photo.IsMain) throw new BadRequestException("This photo cannot be deleted");

        if (photo.PublicId != null)
        {
            var result = await fileService.DeleteFileAsync(photo.PublicId, ResourceType.Image);
            if (result.Error != null) throw new BadRequestException(result.Error.Message);
        }

        user.Photos.Remove(photo);

        if (await userRepository.SaveChangesAsync()) return true;

        throw new BadRequestException("Problem deleting photo");
    }
}
