using AutoMapper;
using CourtService.Core.Application.DTOs;
using CourtService.Core.Domain.Entities;
using SharedKernel.DTOs;

namespace CourtService.Core.Application.Mappings;

public class AutoMapperProfile : Profile
{
    public AutoMapperProfile()
    {
        CreateMap<Court, CourtDto>();
        CreateMap<AddCourtDto, Court>();
        CreateMap<UpdateCourtDto, Court>();
        CreateMap<DateTimePeriod, DateTimePeriodDto>().ReverseMap();
        CreateMap<DateTime, DateTime>().ConvertUsing(d => DateTime.SpecifyKind(d, DateTimeKind.Utc));
        CreateMap<DateTime?, DateTime?>()
            .ConvertUsing(d => d.HasValue ? DateTime.SpecifyKind(d.Value, DateTimeKind.Utc) : null);
    }
}
