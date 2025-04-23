using MediatR;

namespace AuthService.Core.Application.Commands;

public interface ICommand<out TResponse> : IRequest<TResponse>
{
}
