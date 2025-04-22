using FacilityService.Core.Application.Commands;
using MediatR;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public interface ICommandHandler<in TCommand, TResponse> : IRequestHandler<TCommand, TResponse>
    where TCommand : ICommand<TResponse>
{
}
