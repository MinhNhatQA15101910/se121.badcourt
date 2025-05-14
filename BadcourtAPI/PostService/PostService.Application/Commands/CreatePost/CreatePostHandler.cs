using AutoMapper;
using Microsoft.AspNetCore.Http;
using PostService.Application.Extensions;
using PostService.Application.Interfaces;
using PostService.Domain.Entities;
using PostService.Domain.Enums;
using PostService.Domain.Interfaces;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace PostService.Application.Commands.CreatePost;

public class CreatePostHandler(
    IHttpContextAccessor httpContextAccessor,
    IFileService fileService,
    IPostRepository postRepository,
    IMapper mapper
) : ICommandHandler<CreatePostCommand, PostDto>
{
    private static readonly string[] ImageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".webp"];
    private static readonly string[] VideoExtensions = [".mp4", ".avi", ".mov", ".wmv", ".flv", ".mkv", ".webm"];

    public async Task<PostDto> Handle(CreatePostCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        request.CreatePostDto.UserId = userId.ToString();

        var post = mapper.Map<Post>(request.CreatePostDto);

        await postRepository.CreatePostAsync(post, cancellationToken);

        var isMain = true;
        foreach (var resource in request.CreatePostDto.Resources)
        {
            var fileType = GetFileType(resource);
            Domain.Entities.File file;
            if (fileType == FileType.Image)
            {
                var uploadResult = await fileService.UploadPhotoAsync($"posts/{post.Id}", resource);
                if (uploadResult.Error != null)
                    throw new BadRequestException(uploadResult.Error.Message);

                file = new Domain.Entities.File
                {
                    Url = uploadResult.SecureUrl.AbsoluteUri,
                    PublicId = uploadResult.PublicId,
                    IsMain = isMain,
                    FileType = fileType
                };
            }
            else if (fileType == FileType.Video)
            {
                var uploadResult = await fileService.UploadVideoAsync($"posts/{post.Id}", resource);
                if (uploadResult.Error != null)
                    throw new BadRequestException(uploadResult.Error.Message);

                file = new Domain.Entities.File
                {
                    Url = uploadResult.SecureUrl.AbsoluteUri,
                    PublicId = uploadResult.PublicId,
                    IsMain = isMain,
                    FileType = fileType
                };
            }
            else
            {
                throw new BadRequestException("Unsupported file type");
            }

            post.Resources = [.. post.Resources, file];

            isMain = false;
        }

        post.UpdatedAt = DateTime.UtcNow;

        await postRepository.UpdatePostAsync(post, cancellationToken);

        return mapper.Map<PostDto>(post);
    }

    public static FileType GetFileType(IFormFile file)
    {
        if (file == null || string.IsNullOrEmpty(file.FileName))
            return FileType.Unknown;

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();

        if (ImageExtensions.Contains(extension))
            return FileType.Image;
        if (VideoExtensions.Contains(extension))
            return FileType.Video;

        return FileType.Unknown;
    }
}
