using FacilityService.Core.Application.Commands;
using FacilityService.Core.Application.Extensions;
using FacilityService.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public class DeleteFacilityHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityRepository facilityRepository
) : ICommandHandler<DeleteFacilityCommand, bool>
{
    public async Task<bool> Handle(DeleteFacilityCommand request, CancellationToken cancellationToken)
    {
        var facility = await facilityRepository.GetFacilityByIdAsync(request.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(request.FacilityId);

        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (!roles.Contains("Admin"))
        {
            var userId = httpContextAccessor.HttpContext.User.GetUserId();
            if (facility.UserId != userId)
            {
                throw new ForbiddenAccessException("You do not have permission to delete this facility.");
            }
        }

        return true;
    }
}
