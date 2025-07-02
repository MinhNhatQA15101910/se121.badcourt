using AutoMapper;
using FacilityService.Core.Application.Commands;
using FacilityService.Core.Application.Extensions;
using FacilityService.Core.Domain.Entities;
using FacilityService.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public class UpdateActiveHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityRepository facilityRepository,
    IMapper mapper
) : ICommandHandler<UpdateActiveCommand, bool>
{
    private static TimePeriodDto? ConvertToUtc(TimePeriodDto? dto, TimeZoneInfo sourceTimeZone)
    {
        if (dto is null) return null;

        var hourFromUtc = ConvertTimeOnlyToUtc(dto.HourFrom, sourceTimeZone);
        var hourToUtc = ConvertTimeOnlyToUtc(dto.HourTo, sourceTimeZone);

        return new TimePeriodDto
        {
            HourFrom = hourFromUtc,
            HourTo = hourToUtc
        };
    }

    private static TimeOnly ConvertTimeOnlyToUtc(TimeOnly localTime, TimeZoneInfo sourceTimeZone)
    {
        var today = DateTime.UtcNow.Date;
        var localDateTime = new DateTime(
            today.Year, today.Month, today.Day,
            localTime.Hour, localTime.Minute, localTime.Second,
            DateTimeKind.Unspecified);

        var utcDateTime = TimeZoneInfo.ConvertTimeToUtc(localDateTime, sourceTimeZone);

        return TimeOnly.FromDateTime(utcDateTime);
    }

    public async Task<bool> Handle(UpdateActiveCommand request, CancellationToken cancellationToken)
    {
        var currentUserId = httpContextAccessor.HttpContext.User.GetUserId();
        var roles = httpContextAccessor.HttpContext.User.GetRoles();

        var facility = await facilityRepository.GetFacilityByIdAsync(request.FacilityId, cancellationToken)
            ?? throw new FacilityNotFoundException(request.FacilityId);

        if (!roles.Contains("Admin") && facility.UserId != currentUserId)
            throw new ForbiddenAccessException("You do not have permission to update this facility.");

        TimeZoneInfo sourceTimeZone;

        try
        {
            sourceTimeZone = TimeZoneInfo.FindSystemTimeZoneById(request.UpdateActiveDto.TimeZoneId);
        }
        catch (TimeZoneNotFoundException)
        {
            throw new ArgumentException($"Invalid time zone ID: {request.UpdateActiveDto.TimeZoneId}");
        }

        var adjustedActiveDto = new ActiveDto
        {
            Monday = ConvertToUtc(request.UpdateActiveDto.Active.Monday, sourceTimeZone),
            Tuesday = ConvertToUtc(request.UpdateActiveDto.Active.Tuesday, sourceTimeZone),
            Wednesday = ConvertToUtc(request.UpdateActiveDto.Active.Wednesday, sourceTimeZone),
            Thursday = ConvertToUtc(request.UpdateActiveDto.Active.Thursday, sourceTimeZone),
            Friday = ConvertToUtc(request.UpdateActiveDto.Active.Friday, sourceTimeZone),
            Saturday = ConvertToUtc(request.UpdateActiveDto.Active.Saturday, sourceTimeZone),
            Sunday = ConvertToUtc(request.UpdateActiveDto.Active.Sunday, sourceTimeZone),
        };

        facility.ActiveAt = mapper.Map<Active>(adjustedActiveDto);
        facility.UpdatedAt = DateTime.UtcNow;

        await facilityRepository.UpdateFacilityAsync(facility, cancellationToken);

        return true;
    }
}
