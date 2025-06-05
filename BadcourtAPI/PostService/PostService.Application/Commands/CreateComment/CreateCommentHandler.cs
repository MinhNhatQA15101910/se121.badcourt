using AutoMapper;
using MassTransit;
using MediatR;
using Microsoft.AspNetCore.Http;
using MongoDB.Bson;
using PostService.Application.ApiRepositories;
using PostService.Application.Extensions;
using PostService.Application.Interfaces;
using PostService.Application.Notifications;
using PostService.Domain.Entities;
using PostService.Domain.Enums;
using PostService.Domain.Interfaces;
using SharedKernel.DTOs;
using SharedKernel.Events;
using SharedKernel.Exceptions;

namespace PostService.Application.Commands.CreateComment;

public class CreateCommentHandler(
    IHttpContextAccessor httpContextAccessor,
    IPostRepository postRepository,
    ICommentRepository commentRepository,
    IUserApiRepository userApiRepository,
    IFileService fileService,
    IMapper mapper,
    IMediator mediator,
    IPublishEndpoint publishEndpoint
) : ICommandHandler<CreateCommentCommand, CommentDto>
{
    private static readonly string[] ImageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".webp"];
    private static readonly string[] VideoExtensions = [".mp4", ".avi", ".mov", ".wmv", ".flv", ".mkv", ".webm"];

    public async Task<CommentDto> Handle(CreateCommentCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        var post = await postRepository.GetPostByIdAsync(request.CreateCommentDto.PostId, cancellationToken)
            ?? throw new PostNotFoundExceptions(request.CreateCommentDto.PostId);

        var comment = mapper.Map<Comment>(request.CreateCommentDto);

        var user = await userApiRepository.GetUserByIdAsync(userId)
            ?? throw new UserNotFoundException(userId);

        comment.PublisherId = userId;
        comment.PublisherUsername = user.Username;
        comment.PublisherImageUrl = user.Photos.FirstOrDefault(p => p.IsMain)?.Url ?? string.Empty;

        await commentRepository.CreateCommentAsync(comment, cancellationToken);

        var isMain = true;
        foreach (var resource in request.CreateCommentDto.Resources)
        {
            var fileType = GetFileType(resource);
            Domain.Entities.File file;
            if (fileType == FileType.Image)
            {
                var uploadResult = await fileService.UploadPhotoAsync($"comments/{comment.Id}", resource);
                if (uploadResult.Error != null)
                    throw new BadRequestException(uploadResult.Error.Message);

                file = new Domain.Entities.File
                {
                    Id = ObjectId.GenerateNewId().ToString(),
                    Url = uploadResult.SecureUrl.AbsoluteUri,
                    PublicId = uploadResult.PublicId,
                    IsMain = isMain,
                    FileType = fileType
                };
            }
            else if (fileType == FileType.Video)
            {
                var uploadResult = await fileService.UploadVideoAsync($"comments/{comment.Id}", resource);
                if (uploadResult.Error != null)
                    throw new BadRequestException(uploadResult.Error.Message);

                file = new Domain.Entities.File
                {
                    Id = ObjectId.GenerateNewId().ToString(),
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

            comment.Resources = [.. comment.Resources, file];

            isMain = false;
        }

        comment.UpdatedAt = DateTime.UtcNow;
        await commentRepository.UpdateCommentAsync(comment, cancellationToken);

        await mediator.Publish(
            new CommentCreatedNotification(comment.PostId, userId.ToString()),
            cancellationToken
        );

        if (userId.ToString() != post.PublisherId.ToString())
        {
            await publishEndpoint.Publish(
                new PostCommentedEvent(comment.Id, post.PublisherId.ToString(), user.Username, request.CreateCommentDto.Content),
                cancellationToken
            );
        }

        return mapper.Map<CommentDto>(comment);
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
