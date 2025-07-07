using AutoMapper;
using CourtService.Core.Application.Commands;
using CourtService.Core.Application.Extensions;
using CourtService.Core.Application.Interfaces.ServiceClients;
using CourtService.Core.Domain.Entities;
using CourtService.Core.Domain.Enums;
using CourtService.Core.Domain.Repositories;
using MassTransit;
using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Handlers.CommandHandlers;

public class AddCourtHandler(
    IHttpContextAccessor httpContextAccessor,
    ICourtRepository courtRepository,
    IFacilityServiceClient facilityServiceClient,
    IMapper mapper,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<AddCourtCommand, CourtDto>
{
    public async Task<CourtDto> Handle(AddCourtCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        var facility = await facilityServiceClient.GetFacilityByIdAsync(request.AddCourtDto.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(request.AddCourtDto.FacilityId);

        if (facility.UserState == "Locked")
        {
            throw new FacilityLockedException(facility.Id);
        }

        if (facility.UserId != userId)
        {
            throw new ForbiddenAccessException("You do not have permission to add a court to this facility.");
        }

        var existingCourt = await courtRepository.GetCourtByNameAsync(
            request.AddCourtDto.CourtName,
            request.AddCourtDto.FacilityId,
            cancellationToken
        );
        if (existingCourt != null)
        {
            throw new BadRequestException("Court name already exists in this facility.");
        }

        var court = mapper.Map<Court>(request.AddCourtDto);

        await courtRepository.AddCourtAsync(court, cancellationToken);

        await publishEndpoint.Publish(new CourtCreatedEvent(court.FacilityId, court.PricePerHour), cancellationToken);

        return mapper.Map<CourtDto>(court);
    }
}
