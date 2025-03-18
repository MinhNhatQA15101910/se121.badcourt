using MediatR;

namespace Application.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
