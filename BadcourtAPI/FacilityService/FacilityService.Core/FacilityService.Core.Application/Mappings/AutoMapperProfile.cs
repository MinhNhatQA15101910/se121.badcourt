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
        CreateMap<DateTime, DateTime>().ConvertUsing(d => DateTime.SpecifyKind(d, DateTimeKind.Utc));
        CreateMap<DateTime?, DateTime?>()
            .ConvertUsing(d => d.HasValue ? DateTime.SpecifyKind(d.Value, DateTimeKind.Utc) : null);
    }
}
