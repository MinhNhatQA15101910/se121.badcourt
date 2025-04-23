using MediatR;

namespace CourtService.Core.Application.Queries;

public interface IQuery<out TResponse> : IRequest<TResponse>
{
}
