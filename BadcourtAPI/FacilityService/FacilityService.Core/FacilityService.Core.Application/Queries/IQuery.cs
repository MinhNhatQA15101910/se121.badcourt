using MediatR;

namespace FacilityService.Core.Application.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
