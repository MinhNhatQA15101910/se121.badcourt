using SharedKernel.DTOs;

namespace PostService.Application.Commands.CreateComment;

public record CreateCommentCommand(CreateCommentDto CreateCommentDto) : ICommand<CommentDto>;
