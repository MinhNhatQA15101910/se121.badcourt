using AutoMapper;
using RealtimeService.Domain.Entities;
using SharedKernel.DTOs;

namespace RealtimeService.Presentation.Mappings;

public class AutoMapperProfile : Profile
{
    public AutoMapperProfile()
    {
        CreateMap<Message, MessageDto>();
    }
}
