using AutoMapper;
using OrderService.Core.Domain.Entities;
using SharedKernel.DTOs;

namespace OrderService.Core.Application.Mappings;

public class AutoMapperProfile : Profile
{
    public AutoMapperProfile()
    {
        CreateMap<DateTimePeriod, DateTimePeriodDto>().ReverseMap();
        CreateMap<Order, OrderDto>();
    }
}
