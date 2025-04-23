using FacilityService.Core.Application.Queries;
using MediatR;

namespace FacilityService.Core.Application.Handlers.QueryHandlers;

public interface IQueryHandler<in TQuery, TResponse> : IRequestHandler<TQuery, TResponse>
    where TQuery : IQuery<TResponse>
{
}
