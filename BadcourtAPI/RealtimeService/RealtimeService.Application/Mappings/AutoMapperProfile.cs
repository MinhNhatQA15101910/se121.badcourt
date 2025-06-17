using AutoMapper;
using RealtimeService.Domain.Entities;
using SharedKernel.DTOs;

namespace RealtimeService.Application.Mappings;

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

        CreateMap<UserPhoto, PhotoDto>(); // ✅ Thêm dòng này

        CreateMap<User, UserDto>()
            .ForMember(
                d => d.PhotoUrl,
                o => o.MapFrom(
                    s => s.Photos.FirstOrDefault(x => x.IsMain)!.Url
                )
            );
    }
}

