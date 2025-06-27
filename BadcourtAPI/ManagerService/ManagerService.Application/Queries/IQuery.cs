using MediatR;

namespace ManagerService.Application.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
