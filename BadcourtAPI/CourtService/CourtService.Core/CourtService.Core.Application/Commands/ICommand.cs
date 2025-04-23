using MediatR;

namespace CourtService.Core.Application.Commands;

public interface ICommand<out TResponse> : IRequest<TResponse>
{
}
