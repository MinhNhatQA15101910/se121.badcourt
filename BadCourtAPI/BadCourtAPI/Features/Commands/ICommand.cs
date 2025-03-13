using MediatR;

namespace BadCourtAPI.Features.Commands;

public interface ICommand<out TResponse> : IRequest<TResponse>
{
}
