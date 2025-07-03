using AutoMapper;
using CourtService.Core.Application.Commands;
using CourtService.Core.Application.Extensions;
using CourtService.Core.Application.Interfaces.ServiceClients;
using CourtService.Core.Domain.Entities;
using CourtService.Core.Domain.Repositories;
using MassTransit;
using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Handlers.CommandHandlers;

public class UpdateInactiveHandler(
    ICourtRepository courtRepository,
    IHttpContextAccessor httpContextAccessor,
    IFacilityServiceClient facilityServiceClient,
    IMapper mapper,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<UpdateInactiveCommand, bool>
{
    public async Task<bool> Handle(UpdateInactiveCommand request, CancellationToken cancellationToken)
    {
        // Convert HourFrom and HourTo from user-local time to UTC
        var timeZoneId = request.UpdateInactiveDto.TimeZoneId;
        DateTime hourFromUtc = ConvertToUtc(request.UpdateInactiveDto.DateTimePeriod.HourFrom, timeZoneId);
        DateTime hourToUtc = ConvertToUtc(request.UpdateInactiveDto.DateTimePeriod.HourTo, timeZoneId);
        var newInactiveDateTimePeriodDto = new DateTimePeriodDto
        {
            HourFrom = hourFromUtc,
            HourTo = hourToUtc
        };

        var userId = httpContextAccessor.HttpContext?.User.GetUserId();

        var court = await courtRepository.GetCourtByIdAsync(request.CourtId, cancellationToken)
            ?? throw new CourtNotFoundException(request.CourtId);

        var facility = await facilityServiceClient.GetFacilityByIdAsync(court.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(court.FacilityId);

        if (facility.UserId != userId)
        {
            throw new ForbiddenAccessException("You do not have permission to update this court.");
        }

        foreach (var inactivePeriod in court.InactivePeriods)
        {
            if (IsIntersecting(mapper.Map<DateTimePeriodDto>(inactivePeriod), newInactiveDateTimePeriodDto))
            {
                throw new BadRequestException("The specified period intersects with an existing inactive period.");
            }
        }

        foreach (var orderPeriod in court.OrderPeriods)
        {
            if (IsIntersecting(mapper.Map<DateTimePeriodDto>(orderPeriod), newInactiveDateTimePeriodDto))
            {
                throw new BadRequestException("The specified period intersects with an existing order period.");
            }
        }

        var dateTimePeriod = mapper.Map<DateTimePeriod>(newInactiveDateTimePeriodDto);
        court.InactivePeriods = [.. court.InactivePeriods, dateTimePeriod];
        court.UpdatedAt = DateTime.UtcNow;

        await courtRepository.UpdateCourtAsync(court, cancellationToken);

        await publishEndpoint.Publish(
            new CourtInactiveUpdatedEvent(request.CourtId, newInactiveDateTimePeriodDto),
            cancellationToken
        );

        return true;
    }

    private static bool IsIntersecting(
        DateTimePeriodDto period1,
        DateTimePeriodDto period2
    )
    {
        return period1.HourFrom < period2.HourTo && period2.HourFrom < period1.HourTo;
    }

    private static DateTime ConvertToUtc(DateTime localDateTime, string timeZoneId)
    {
        var timeZone = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);

        if (localDateTime.Kind == DateTimeKind.Utc)
            return localDateTime;

        var unspecified = DateTime.SpecifyKind(localDateTime, DateTimeKind.Unspecified);
        return TimeZoneInfo.ConvertTimeToUtc(unspecified, timeZone);
    }
}
