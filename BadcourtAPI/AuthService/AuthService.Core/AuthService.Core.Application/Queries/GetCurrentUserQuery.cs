using SharedKernel.DTOs;

namespace AuthService.Core.Application.Queries;

public record GetCurrentUserQuery : IQuery<UserDto>;
