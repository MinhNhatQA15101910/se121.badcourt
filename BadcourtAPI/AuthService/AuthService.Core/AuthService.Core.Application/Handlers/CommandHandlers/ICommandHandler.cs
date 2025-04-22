using AuthService.Core.Application.Commands;
using MediatR;

namespace AuthService.Core.Application.Handlers.CommandHandlers;

public interface ICommandHandler<in TCommand, TResponse> : IRequestHandler<TCommand, TResponse>
    where TCommand : ICommand<TResponse>
{
}
