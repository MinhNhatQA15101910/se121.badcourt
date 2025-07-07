using FacilityService.Core.Application.Commands;
using FacilityService.Core.Application.Extensions;
using FacilityService.Core.Application.ExternalServices.Interfaces;
using FacilityService.Core.Domain.Enums;
using FacilityService.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;
using SharedKernel.Exceptions;
using SharedKernel.Params;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public class DeleteFacilityHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityRepository facilityRepository,
    IOrderServiceClient orderServiceClient
) : ICommandHandler<DeleteFacilityCommand, bool>
{
    public async Task<bool> Handle(DeleteFacilityCommand request, CancellationToken cancellationToken)
    {
        var facility = await facilityRepository.GetFacilityByIdAsync(request.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(request.FacilityId);

        if (facility.UserState == UserState.Locked)
        {
            throw new FacilityLockedException(facility.Id);
        }

        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (!roles.Contains("Admin"))
        {
            var userId = httpContextAccessor.HttpContext.User.GetUserId();
            if (facility.UserId != userId)
            {
                throw new ForbiddenAccessException("You do not have permission to delete this facility.");
            }
        }

        var notPlayedOrders = await orderServiceClient.GetOrdersAsync(new OrderParams
        {
            FacilityId = request.FacilityId,
            HourFrom = DateTime.UtcNow,
        });
        if (notPlayedOrders != null && notPlayedOrders.Any())
        {
            throw new BadRequestException("Cannot delete facility with existing orders.");
        }

        await facilityRepository.DeleteFacilityAsync(facility, cancellationToken);

        return true;
    }
}
