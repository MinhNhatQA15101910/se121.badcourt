using MediatR;

namespace OrderService.Core.Application.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
