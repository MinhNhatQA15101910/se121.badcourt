using BadCourtAPI.Features.Queries;
using MediatR;

namespace BadCourtAPI.Features.Handlers.QueryHandlers;

public interface IQueryHandler<in TQuery, TResponse> : IRequestHandler<TQuery, TResponse>
    where TQuery : IQuery<TResponse>
{
}
