using Application.Commands.Users;
using Domain.Exceptions;
using Domain.Repositories;

namespace Application.Handlers.CommandHandlers.Users;

public class SetMainPhotoHandler(IUnitOfWork unitOfWork) : ICommandHandler<SetMainPhotoCommand, bool>
{
    public async Task<bool> Handle(SetMainPhotoCommand request, CancellationToken cancellationToken)
    {
        var user = await unitOfWork.UserRepository.GetUserByIdAsync(request.UserId)
            ?? throw new UserNotFoundException(request.UserId);

        var photo = user.Photos.FirstOrDefault(x => x.Id == request.PhotoId);

        if (photo == null || photo.IsMain) throw new BadRequestException("Cannot use this as main photo");

        var currentMain = user.Photos.FirstOrDefault(x => x.IsMain);
        if (currentMain != null) currentMain.IsMain = false;

        photo.IsMain = true;

        if (await unitOfWork.Complete()) return true;

        throw new BadRequestException("Problem setting main photo");
    }
}
