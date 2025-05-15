using MediatR;

namespace PostService.Application.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
