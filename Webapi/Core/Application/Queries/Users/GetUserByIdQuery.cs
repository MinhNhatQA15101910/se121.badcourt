using SharedKernel.DTOs;

namespace Application.Queries.Users;

public record GetUserByIdQuery(Guid Id) : IQuery<UserDto>;
