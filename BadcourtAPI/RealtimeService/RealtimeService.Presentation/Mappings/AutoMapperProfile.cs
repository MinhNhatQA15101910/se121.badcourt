using AutoMapper;
using RealtimeService.Domain.Entities;
using SharedKernel.DTOs;

namespace RealtimeService.Presentation.Mappings;

public class AutoMapperProfile : Profile
{
    public AutoMapperProfile()
    {
        CreateMap<Message, MessageDto>();
        CreateMap<Group, GroupDto>()
            .ForMember(dest => dest.Users, opt => opt.Ignore())
            .ForMember(dest => dest.LastMessage, opt => opt.Ignore())
            .ForMember(dest => dest.Connections, opt => opt.Ignore());
        CreateMap<Connection, ConnectionDto>();
        CreateMap<DateTime, DateTime>().ConvertUsing(d => DateTime.SpecifyKind(d, DateTimeKind.Utc));
        CreateMap<DateTime?, DateTime?>()
            .ConvertUsing(d => d.HasValue ? DateTime.SpecifyKind(d.Value, DateTimeKind.Utc) : null);
    }
}
