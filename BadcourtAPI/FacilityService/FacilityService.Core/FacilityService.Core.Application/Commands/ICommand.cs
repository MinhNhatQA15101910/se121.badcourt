using MediatR;

namespace FacilityService.Core.Application.Commands;

public interface ICommand<out TResponse> : IRequest<TResponse>
{
}
