using CourtService.Core.Application.Commands;
using MediatR;

namespace CourtService.Core.Application.Handlers.CommandHandlers;

public interface ICommandHandler<in TCommand, TResponse> : IRequestHandler<TCommand, TResponse>
    where TCommand : ICommand<TResponse>
{
}
