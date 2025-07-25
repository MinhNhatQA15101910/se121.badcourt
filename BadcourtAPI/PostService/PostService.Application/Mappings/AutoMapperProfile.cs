using AutoMapper;
using PostService.Application.Commands.CreateComment;
using PostService.Application.Commands.CreatePost;
using PostService.Domain.Entities;
using SharedKernel.DTOs;

namespace PostService.Application.Mappings;

public class AutoMapperProfile : Profile
{
    public AutoMapperProfile()
    {
        CreateMap<Domain.Entities.File, FileDto>();

        CreateMap<CreatePostDto, Post>()
            .ForMember(dest => dest.Resources, opt => opt.Ignore());
        CreateMap<Post, PostDto>();

        CreateMap<CreateCommentDto, Comment>()
            .ForMember(dest => dest.Resources, opt => opt.Ignore());
        CreateMap<Comment, CommentDto>();
        CreateMap<DateTime, DateTime>().ConvertUsing(d => DateTime.SpecifyKind(d, DateTimeKind.Utc));
        CreateMap<DateTime?, DateTime?>()
            .ConvertUsing(d => d.HasValue ? DateTime.SpecifyKind(d.Value, DateTimeKind.Utc) : null);
    }
}
