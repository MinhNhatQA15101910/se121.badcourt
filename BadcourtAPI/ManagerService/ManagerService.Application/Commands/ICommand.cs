using MediatR;

namespace ManagerService.Application.Commands;

public interface ICommand<out TResponse> : IRequest<TResponse>
{
}
