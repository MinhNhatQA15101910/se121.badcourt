using AuthService.Core.Application.Queries;
using AuthService.Core.Domain.Repositories;
using AutoMapper;
using SharedKernel.DTOs;

namespace AuthService.Core.Application.Handlers.QueryHandlers;

public class GetAdminBriefInfoHandler(
    IUserRepository userRepository,
    IMapper mapper
) : IQueryHandler<GetAdminBriefInfoQuery, UserBriefDto>
{
    public async Task<UserBriefDto> Handle(GetAdminBriefInfoQuery request, CancellationToken cancellationToken)
    {
        var admin = await userRepository.GetAdminAsync(cancellationToken)
            ?? throw new InvalidOperationException("Admin not found");

        return mapper.Map<UserBriefDto>(admin);
    }
}
