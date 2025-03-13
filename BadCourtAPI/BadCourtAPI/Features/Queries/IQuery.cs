using MediatR;

namespace BadCourtAPI.Features.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
