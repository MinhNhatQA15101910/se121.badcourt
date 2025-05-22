using AuthService.Core.Application.DTOs;
using AuthService.Core.Domain.Entities;
using AutoMapper;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Mappings;

public class AutoMapperProfiles : Profile
{
    public AutoMapperProfiles()
    {
        CreateMap<UserPhoto, PhotoDto>();
        CreateMap<User, UserDto>()
            .ForMember(
                d => d.PhotoUrl,
                o => o.MapFrom(
                    s => s.Photos.FirstOrDefault(x => x.IsMain)!.Url
                )
            )
            .ForMember(
                d => d.Roles,
                o => o.MapFrom(
                    s => s.UserRoles.Select(x => x.Role.Name)
                )
            );
        CreateMap<ValidateSignupDto, User>();
        CreateMap<DateTime, DateTime>().ConvertUsing(d => DateTime.SpecifyKind(d, DateTimeKind.Utc));
        CreateMap<DateTime?, DateTime?>()
            .ConvertUsing(d => d.HasValue ? DateTime.SpecifyKind(d.Value, DateTimeKind.Utc) : null);
    }
}
