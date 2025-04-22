using AuthService.Core.Application.Commands;
using AuthService.Core.Domain.Repositories;
using SharedKernel.Exceptions;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public class SetMainPhotoHandler(IUserRepository userRepository) : ICommandHandler<SetMainPhotoCommand, bool>
{
    public async Task<bool> Handle(SetMainPhotoCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetUserByIdAsync(request.UserId)
            ?? throw new UserNotFoundException(request.UserId);

        var photo = user.Photos.FirstOrDefault(x => x.Id == request.PhotoId);

        if (photo == null || photo.IsMain) throw new BadRequestException("Cannot use this as main photo");

        var currentMain = user.Photos.FirstOrDefault(x => x.IsMain);
        if (currentMain != null) currentMain.IsMain = false;

        photo.IsMain = true;

        if (await userRepository.SaveChangesAsync()) return true;

        throw new BadRequestException("Problem setting main photo");
    }
}
