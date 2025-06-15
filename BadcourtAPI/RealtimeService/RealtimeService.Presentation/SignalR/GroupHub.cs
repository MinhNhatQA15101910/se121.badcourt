using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class GroupHub(
    IGroupRepository groupRepository,
    IMessageRepository messageRepository,
    IConnectionRepository connectionRepository,
    IUserRepository userRepository,
    IMapper mapper
) : Hub
{
    public override async Task OnConnectedAsync()
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        var userId = Context.User.GetUserId().ToString();

        var groups = await groupRepository.GetGroupsRawAsync(userId, new GroupParams
        {
            PageNumber = 1,
            PageSize = 20
        });
        var groupDtos = groups.Select(mapper.Map<GroupDto>).ToList();

        for (var i = 0; i < groups.Count; i++)
        {
            // Set connections
            var groupConnections = await connectionRepository.GetConnectionsByGroupIdAsync(groups[i].Id);
            groupDtos[i].Connections = [.. groupConnections.Select(mapper.Map<ConnectionDto>)];

            // Set users
            foreach (var userIdInGroup in groups[i].UserIds)
            {
                var userDto = await userRepository.GetUserByIdAsync(Guid.Parse(userIdInGroup)).ConfigureAwait(false)
                    ?? throw new HubException($"User with ID {userIdInGroup} not found");
                groupDtos[i].Users.Add(mapper.Map<UserDto>(userDto));
            }

            // Set last message
            var lastMessage = await messageRepository.GetLastMessageAsync(groups[i].Id);
            if (lastMessage != null)
            {
                groupDtos[i].LastMessage = mapper.Map<MessageDto>(lastMessage);
            }
        }

        var pagedGroupDtos = new PagedResult<GroupDto>
        {
            CurrentPage = groups.CurrentPage,
            TotalPages = groups.TotalPages,
            PageSize = groups.PageSize,
            TotalCount = groups.TotalCount,
            Items = groupDtos
        };

        await Clients.Caller.SendAsync("ReceiveGroups", pagedGroupDtos);
    }
}
