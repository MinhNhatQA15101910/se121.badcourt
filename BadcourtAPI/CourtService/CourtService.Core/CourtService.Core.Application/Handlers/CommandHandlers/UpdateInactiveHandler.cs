using AutoMapper;
using CourtService.Core.Application.ApiRepositories;
using CourtService.Core.Application.Commands;
using CourtService.Core.Application.Extensions;
using CourtService.Core.Domain.Entities;
using CourtService.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace CourtService.Core.Application.Handlers.CommandHandlers;

public class UpdateInactiveHandler(
    ICourtRepository courtRepository,
    IHttpContextAccessor httpContextAccessor,
    IFacilityApiRepository facilityApiRepository,
    IMapper mapper
) : ICommandHandler<UpdateInactiveCommand, bool>
{
    public async Task<bool> Handle(UpdateInactiveCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext?.User.GetUserId();
        
        var court = await courtRepository.GetCourtByIdAsync(request.CourtId, cancellationToken)
            ?? throw new CourtNotFoundException(request.CourtId);

        var facility = await facilityApiRepository.GetFacilityByIdAsync(court.FacilityId)
            ?? throw new FacilityNotFoundException(court.FacilityId);

        if (facility.UserId != userId)
        {
            throw new ForbiddenAccessException("You do not have permission to update this court.");
        }

        foreach (var inactivePeriod in court.InactivePeriods)
        {
            if (IsIntersecting(mapper.Map<DateTimePeriodDto>(inactivePeriod), request.DateTimePeriodDto))
            {
                throw new BadRequestException("The specified period intersects with an existing inactive period.");
            }
        }

        foreach (var orderPeriod in court.OrderPeriods)
        {
            if (IsIntersecting(mapper.Map<DateTimePeriodDto>(orderPeriod), request.DateTimePeriodDto))
            {
                throw new BadRequestException("The specified period intersects with an existing order period.");
            }
        }

        var dateTimePeriod = mapper.Map<DateTimePeriod>(request.DateTimePeriodDto);
        court.InactivePeriods = [.. court.InactivePeriods, dateTimePeriod];
        court.UpdatedAt = DateTime.UtcNow;

        await courtRepository.UpdateCourtAsync(court, cancellationToken);
        return true;
    }

    private static bool IsIntersecting(
        DateTimePeriodDto period1,
        DateTimePeriodDto period2
    )
    {
        return period1.HourFrom < period2.HourTo && period2.HourFrom < period1.HourTo;
    }
}
