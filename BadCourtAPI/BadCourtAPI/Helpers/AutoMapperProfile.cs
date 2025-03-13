using AutoMapper;
using BadCourtAPI.Dtos.Photos;
using BadCourtAPI.Dtos.Users;
using BadCourtAPI.Entities;

namespace BadCourtAPI.Helpers;

public class AutoMapperProfile : Profile
{
    public AutoMapperProfile()
    {
        CreateMap<UserPhoto, PhotoDto>();
        CreateMap<User, UserDto>()
            .ForMember(
                x => x.PhotoUrl,
                e => e.MapFrom(
                    x => x.Photos.FirstOrDefault(x1 => x1.IsMain)!.Url
                )
            )
            .ForMember(
                x => x.Roles,
                e => e.MapFrom(
                    x => x.UserRoles.Select(x1 => x1.Role.Name).ToList()
                )
            );
    }
}
