using MediatR;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace AuthService.Core.Application.Queries;

public record GetUsersQuery(UserParams UserParams) : IRequest<PagedList<UserDto>>;
