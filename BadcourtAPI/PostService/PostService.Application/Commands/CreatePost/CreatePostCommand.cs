using SharedKernel.DTOs;

namespace PostService.Application.Commands.CreatePost;

public record CreatePostCommand(CreatePostDto CreatePostDto) : ICommand<PostDto>;
