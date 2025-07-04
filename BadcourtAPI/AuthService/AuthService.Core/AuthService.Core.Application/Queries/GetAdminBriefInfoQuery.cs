using SharedKernel.DTOs;

namespace AuthService.Core.Application.Queries;

public record GetAdminBriefInfoQuery : IQuery<UserBriefDto>;
