using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.ApiRepositories;
using RealtimeService.Presentation.Extensions;
using SharedKernel.DTOs;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class GroupHub(
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

        var groups = await groupRepository.GetGroupsForUserAsync(userId);

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
                    ?? throw new HubException($"User with ID {userId} not found");
                groupDtos[i].Users.Add(userDto);
            }

            // Set last message
            var lastMessage = await messageRepository.GetLastMessageAsync(groups[i].Id);
            if (lastMessage != null)
            {
                groupDtos[i].LastMessage = mapper.Map<MessageDto>(lastMessage);
            }
        }

        await Clients.Caller.SendAsync("ReceiveGroups", groupDtos);
    }
}
