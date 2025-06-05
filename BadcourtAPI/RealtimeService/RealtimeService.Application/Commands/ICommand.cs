using MediatR;

namespace RealtimeService.Application.Commands;

public interface ICommand<out TResponse> : IRequest<TResponse>
{
}
