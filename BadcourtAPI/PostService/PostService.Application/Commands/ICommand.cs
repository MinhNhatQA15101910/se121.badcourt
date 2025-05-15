using MediatR;

namespace PostService.Application.Commands;

public interface ICommand<out TResponse> : IRequest<TResponse>
{
}
