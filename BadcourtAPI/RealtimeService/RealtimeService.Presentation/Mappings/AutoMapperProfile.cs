using AutoMapper;
using RealtimeService.Domain.Entities;
using SharedKernel;
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
        CreateMap<Notification, NotificationDto>()
            .ForMember(dest => dest.Type, opt => opt.MapFrom(src => src.Type.ToString()));
        CreateMap<NotificationData, NotificationDataDto>();
        CreateMap(typeof(PagedList<>), typeof(PagedResult<>))
            .ForMember("Items", opt => opt.MapFrom(src => (IEnumerable<object>)src))
            .ForMember("CurrentPage", opt => opt.MapFrom("CurrentPage"))
            .ForMember("TotalPages", opt => opt.MapFrom("TotalPages"))
            .ForMember("PageSize", opt => opt.MapFrom("PageSize"))
            .ForMember("TotalCount", opt => opt.MapFrom("TotalCount"));
        // CreateMap<DateTime, DateTime>().ConvertUsing(
        //     d => DateTime.SpecifyKind(d, DateTimeKind.Utc)
        // );
        // CreateMap<DateTime?, DateTime?>().ConvertUsing(
        //     d => d.HasValue ? DateTime.SpecifyKind(d.Value, DateTimeKind.Utc) : null
        // );
    }
}
