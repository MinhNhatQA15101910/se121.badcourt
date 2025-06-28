using MediatR;

namespace AdminService.Application.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
