using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace PostService.Application.Queries.GetComments;

public record GetCommentsQuery(CommentParams CommentParams) : IQuery<PagedList<CommentDto>>;
