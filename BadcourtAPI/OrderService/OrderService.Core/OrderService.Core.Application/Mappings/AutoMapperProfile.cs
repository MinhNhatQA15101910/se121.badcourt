using AutoMapper;
using OrderService.Core.Domain.Entities;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Mappings;

public class AutoMapperProfile : Profile
{
    public AutoMapperProfile()
    {
        CreateMap<DateTimePeriod, DateTimePeriodDto>().ReverseMap();
        CreateMap<Rating, RatingDto>();
        CreateMap<Order, OrderDto>()
            .ForMember(dest => dest.State, opt => opt.MapFrom(src => src.State.ToString()));
        CreateMap<DateTime, DateTime>().ConvertUsing(d => DateTime.SpecifyKind(d, DateTimeKind.Utc));
        CreateMap<DateTime?, DateTime?>()
            .ConvertUsing(d => d.HasValue ? DateTime.SpecifyKind(d.Value, DateTimeKind.Utc) : null);
    }
}
