using MediatR;

namespace RealtimeService.Application.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
