using SharedKernel.DTOs;

namespace AuthService.Core.Application.Queries;

public record GetUserByIdQuery(Guid Id) : IQuery<UserDto>;
