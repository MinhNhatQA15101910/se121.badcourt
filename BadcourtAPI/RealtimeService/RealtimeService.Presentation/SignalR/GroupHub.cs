using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Application.ApiRepositories;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;
using SharedKernel;
using SharedKernel.DTOs;
using SharedKernel.Params;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class GroupHub(
    GroupHubTracker groupHubTracker,
    IGroupRepository groupRepository,
    IMessageRepository messageRepository,
    IConnectionRepository connectionRepository,
    IUserApiRepository userApiRepository,
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

        await groupHubTracker.UserConnectedAsync(userId, Context.ConnectionId);

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
                var userDto = await userApiRepository.GetUserByIdAsync(Guid.Parse(userIdInGroup))
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

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        if (Context.User is null)
        {
            throw new HubException("Cannot get current user claims");
        }

        await groupHubTracker.UserDisconnectedAsync(Context.User.GetUserId().ToString(), Context.ConnectionId);

        await base.OnDisconnectedAsync(exception);
    }
}
