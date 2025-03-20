using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Exceptions;
using AuthService.Core.Domain.Repositories;
using AutoMapper;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetUserByIdHandler(
    IUserRepository userRepository,
    IMapper mapper
) : IQueryHandler<GetUserByIdQuery, UserDto>
{
    public async Task<UserDto> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetUserByIdAsync(request.Id)
            ?? throw new UserNotFoundException(request.Id);

        return mapper.Map<UserDto>(user);
    }
}
