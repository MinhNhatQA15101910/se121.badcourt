using AutoMapper;
using CourtService.Core.Application.Commands;
using CourtService.Core.Application.Extensions;
using CourtService.Core.Application.Interfaces.ServiceClients;
using CourtService.Core.Domain.Enums;
using CourtService.Core.Domain.Repositories;
using MassTransit;
using Microsoft.AspNetCore.Http;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Handlers.CommandHandlers;

public class UpdateCourtHandler(
    ICourtRepository courtRepository,
    IHttpContextAccessor httpContextAccessor,
    IFacilityServiceClient facilityServiceClient,
    IPublishEndpoint publishEndpoint,
    IMapper mapper
) : ICommandHandler<UpdateCourtCommand, bool>
{
    public async Task<bool> Handle(UpdateCourtCommand request, CancellationToken cancellationToken)
    {
        var court = await courtRepository.GetCourtByIdAsync(request.CourtId, cancellationToken)
            ?? throw new CourtNotFoundException(request.CourtId);

        if (court.UserState == UserState.Locked) throw new CourtLockedException(court.Id);

        var facilityId = court.FacilityId;
        var facility = await facilityServiceClient.GetFacilityByIdAsync(facilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(facilityId);

        var userId = httpContextAccessor.HttpContext?.User.GetUserId();
        if (userId != facility.UserId)
        {
            throw new ForbiddenAccessException("You are not allowed to update this court.");
        }

        var existingCourt = await courtRepository.GetCourtByNameAsync(request.UpdateCourtDto.CourtName, court.FacilityId, cancellationToken);
        if (existingCourt is not null && existingCourt.Id != request.CourtId)
        {
            throw new BadRequestException("Court with this name already exists in this facility.");
        }

        mapper.Map(request.UpdateCourtDto, court);
        court.UpdatedAt = DateTime.UtcNow;

        await courtRepository.UpdateCourtAsync(court, cancellationToken);

        await publishEndpoint.Publish(new CourtUpdatedEvent(
            FacilityId: court.FacilityId,
            MinPrice: await courtRepository.GetFacilityMinPriceAsync(facilityId, cancellationToken),
            MaxPrice: await courtRepository.GetFacilityMaxPriceAsync(facilityId, cancellationToken)
        ), cancellationToken);

        return true;
    }
}
