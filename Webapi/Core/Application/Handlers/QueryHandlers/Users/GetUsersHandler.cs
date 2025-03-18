using Application.Queries.Users;
using Domain.Repositories;
using MediatR;
using SharedKernel;
using SharedKernel.DTOs;

namespace Application.Handlers.QueryHandlers.Users;

public class GetUsersHandler(IUnitOfWork unitOfWork) : IRequestHandler<GetUsersQuery, PagedList<UserDto>>
{
    public async Task<PagedList<UserDto>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
    {
        return await unitOfWork.UserRepository.GetUsersAsync(request.UserParams);
    }
}
