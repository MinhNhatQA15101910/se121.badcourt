using CourtService.Core.Application.Queries;
using MediatR;

namespace CourtService.Core.Application.Handlers.QueryHandlers;

public interface IQueryHandler<in TQuery, TResponse> : IRequestHandler<TQuery, TResponse>
    where TQuery : IQuery<TResponse>
{
}
