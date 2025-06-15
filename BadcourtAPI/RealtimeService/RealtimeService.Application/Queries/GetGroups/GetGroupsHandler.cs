using AutoMapper;
using Microsoft.AspNetCore.Http;
using RealtimeService.Application.Extensions;
using RealtimeService.Domain.Interfaces;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace RealtimeService.Application.Queries.GetGroups;

public class GetGroupsHandler(
    IHttpContextAccessor httpContextAccessor,
    IGroupRepository groupRepository,
    IConnectionRepository connectionRepository,
    IMessageRepository messageRepository,
    IUserRepository userRepository,
    IMapper mapper
) : IQueryHandler<GetGroupsQuery, PagedResult<GroupDto>>
{
    public async Task<PagedResult<GroupDto>> Handle(GetGroupsQuery request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();

        var groups = await groupRepository
            .GetGroupsRawAsync(userId, request.GroupParams, cancellationToken);
        var groupDtos = groups.Select(mapper.Map<GroupDto>).ToList();

        for (var i = 0; i < groups.Count; i++)
        {
            // Set connections
            var groupConnections = await connectionRepository.GetConnectionsByGroupIdAsync(groups[i].Id, cancellationToken);
            groupDtos[i].Connections = [.. groupConnections.Select(mapper.Map<ConnectionDto>)];

            // Set users
            foreach (var userIdInGroup in groups[i].UserIds)
            {
                var userDto = await userRepository.GetUserByIdAsync(Guid.Parse(userIdInGroup), cancellationToken)
                    ?? throw new UserNotFoundException(Guid.Parse(userIdInGroup));
                groupDtos[i].Users.Add(mapper.Map<UserDto>(userDto));
            }

            // Set last message
            var lastMessage = await messageRepository.GetLastMessageAsync(groups[i].Id, cancellationToken);
            if (lastMessage != null)
            {
                groupDtos[i].LastMessage = mapper.Map<MessageDto>(lastMessage);
            }
        }

        return new PagedResult<GroupDto>
        {
            CurrentPage = groups.CurrentPage,
            TotalPages = groups.TotalPages,
            PageSize = groups.PageSize,
            TotalCount = groups.TotalCount,
            Items = groupDtos
        };
    }
}
