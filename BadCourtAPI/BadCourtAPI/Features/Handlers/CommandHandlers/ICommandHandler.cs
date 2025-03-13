using BadCourtAPI.Features.Commands;
using MediatR;

namespace BadCourtAPI.Features.Handlers.CommandHandlers;

public interface ICommandHandler<in TCommand, TResponse> : IRequestHandler<TCommand, TResponse>
    where TCommand : ICommand<TResponse>
{
}
