using MediatR;

namespace Application.Commands;

public interface ICommand<out TResponse> : IRequest<TResponse>
{
}
