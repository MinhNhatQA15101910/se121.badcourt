using MediatR;

namespace AuthService.Core.Application.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
