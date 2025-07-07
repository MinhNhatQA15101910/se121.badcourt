using CourtService.Core.Application.Commands;
using CourtService.Core.Application.Extensions;
using CourtService.Core.Application.Interfaces.ServiceClients;
using CourtService.Core.Domain.Enums;
using CourtService.Core.Domain.Repositories;
using MassTransit;
using Microsoft.AspNetCore.Http;
using SharedKernel.Events;
using SharedKernel.Exceptions;
using SharedKernel.Params;

namespace CourtService.Core.Application.Handlers.CommandHandlers;

public class DeleteCourtHandler(
    IHttpContextAccessor httpContextAccessor,
    IOrderServiceClient orderServiceClient,
    ICourtRepository courtRepository,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<DeleteCourtCommand, bool>
{
    public async Task<bool> Handle(DeleteCourtCommand request, CancellationToken cancellationToken)
    {
        var court = await courtRepository.GetCourtByIdAsync(request.CourtId, cancellationToken)
            ?? throw new CourtNotFoundException(request.CourtId);

        if (court.UserState == UserState.Locked)
        {
            throw new CourtLockedException(court.Id);
        }

        var roles = httpContextAccessor.HttpContext.User.GetRoles();
        if (!roles.Contains("Admin"))
        {
            var userId = httpContextAccessor.HttpContext.User.GetUserId();
            if (court.UserId != userId.ToString())
            {
                throw new ForbiddenAccessException("You do not have permission to delete this court.");
            }
        }

        var notPlayedOrders = await orderServiceClient.GetOrdersAsync(new OrderParams
        {
            CourtId = request.CourtId,
            HourFrom = DateTime.UtcNow,
            PageSize = 50
        }, cancellationToken);
        if (notPlayedOrders != null && notPlayedOrders.Any())
        {
            throw new BadRequestException("Cannot delete court with existing orders.");
        }

        await courtRepository.DeleteCourtAsync(court, cancellationToken);

        var minPrice = await courtRepository.GetFacilityMinPriceAsync(court.FacilityId, cancellationToken);
        var maxPrice = await courtRepository.GetFacilityMaxPriceAsync(court.FacilityId, cancellationToken);
        var courtDeletedEvent = new CourtDeletedEvent(court.FacilityId, minPrice, maxPrice);
        await publishEndpoint.Publish(courtDeletedEvent, cancellationToken);

        return true;
    }
}
