using MediatR;

namespace OrderService.Core.Application.Commands;

public interface ICommand<out TResponse> : IRequest<TResponse>
{
}
