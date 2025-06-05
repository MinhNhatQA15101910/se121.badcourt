using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Application.Queries.GetGroups;

public record GetGroupsQuery(GroupParams GroupParams) : IQuery<PagedResult<GroupDto>>;
