using AutoMapper;
using FacilityService.Core.Application.DTOs;
using FacilityService.Core.Domain.Entities;
using SharedKernel.DTOs;

namespace FacilityService.Core.Application.Mappings;

public class AutoMapperProfile : Profile
{
    public AutoMapperProfile()
    {
        CreateMap<Active, ActiveDto>().ReverseMap();
        CreateMap<Location, LocationDto>();
        CreateMap<TimePeriod, TimePeriodDto>().ReverseMap();
        CreateMap<FacilityPhoto, PhotoDto>();
        CreateMap<Photo, PhotoDto>();
        CreateMap<ManagerInfo, ManagerInfoDto>();
        CreateMap<Facility, FacilityDto>();
        CreateMap<RegisterFacilityDto, Facility>()
            .ForMember(
                dest => dest.Location,
                opt => opt.MapFrom(src => new Location
                {
                    Type = "Point",
                    Coordinates = new[] { src.Lon, src.Lat }
                })
            )
            .ForMember(
                dest => dest.ManagerInfo,
                opt => opt.MapFrom(src => new ManagerInfo
                {
                    FullName = src.FullName,
                    Email = src.Email,
                    PhoneNumber = src.PhoneNumber,
                    CitizenId = src.CitizenId
                })
            );
        CreateMap<UpdateFacilityDto, Facility>()
            .ForMember(dest => dest.Location, opt => opt.PreCondition(src => src.Lat.HasValue && src.Lon.HasValue))
            .ForMember(
                dest => dest.Location,
                opt => opt.MapFrom(src => new Location
                {
                    Type = "Point",
                    Coordinates = new[] { src.Lon!.Value, src.Lat!.Value }
                })
            )
            .ForMember(dest => dest.ManagerInfo, opt => opt.PreCondition(src =>
                src.FullName != null ||
                src.Email != null ||
                src.PhoneNumber != null ||
                src.CitizenId != null
            ))
            .ForMember(
                dest => dest.ManagerInfo,
                opt => opt.MapFrom((src, dest) =>
                {
                    var manager = dest.ManagerInfo ?? new ManagerInfo();
                    if (src.FullName != null) manager.FullName = src.FullName;
                    if (src.Email != null) manager.Email = src.Email;
                    if (src.PhoneNumber != null) manager.PhoneNumber = src.PhoneNumber;
                    if (src.CitizenId != null) manager.CitizenId = src.CitizenId;
                    return manager;
                })
            )
            .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
        CreateMap<DateTime, DateTime>().ConvertUsing(d => DateTime.SpecifyKind(d, DateTimeKind.Utc));
        CreateMap<DateTime?, DateTime?>()
            .ConvertUsing(d => d.HasValue ? DateTime.SpecifyKind(d.Value, DateTimeKind.Utc) : null);
    }
}
