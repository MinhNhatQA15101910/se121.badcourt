using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Entities;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.ApiRepositories;
using RealtimeService.Presentation.DTOs;
using RealtimeService.Presentation.Extensions;
using SharedKernel.DTOs;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class MessageHub(
    IMessageRepository messageRepository,
    IUserApiRepository userApiRepository,
    IMapper mapper
) : Hub
{
    public override async Task OnConnectedAsync()
    {
        var httpContext = Context.GetHttpContext();
        var otherUser = httpContext?.Request.Query["user"];

        if (Context.User == null || string.IsNullOrEmpty(otherUser))
        {
            throw new HubException("Cannot join group");
        }

        var groupName = GetGroupName(Context.User.GetUserId().ToString(), otherUser);
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

        var messages = await messageRepository.GetMessageThreadAsync(
            Context.User.GetUserId().ToString(),
            otherUser!
        );
        await Clients.Group(groupName).SendAsync("ReceiveMessageThread", messages);
    }

    public override Task OnDisconnectedAsync(Exception? exception)
    {
        return base.OnDisconnectedAsync(exception);
    }

    public async Task SendMessage(CreateMessageDto createMessageDto)
    {
        var userId = Context.User?.GetUserId() ?? throw new Exception("Could not get user");

        if (userId.ToString() == createMessageDto.RecipientId)
        {
            throw new HubException("You cannot send messages to yourself");
        }

        var sender = await userApiRepository.GetUserByIdAsync(userId);
        var recipient = await userApiRepository.GetUserByIdAsync(Guid.Parse(createMessageDto.RecipientId));
        if (sender == null || recipient == null)
        {
            throw new HubException("Cannot send message");
        }

        var message = new Message
        {
            SenderId = sender.Id.ToString(),
            SenderUsername = sender.Username,
            SenderImageUrl = sender.PhotoUrl ?? string.Empty,
            RecipientId = recipient.Id.ToString(),
            RecipientUsername = recipient.Username,
            RecipientImageUrl = recipient.PhotoUrl ?? string.Empty,
            Content = createMessageDto.Content,
        };

        await messageRepository.AddMessageAsync(message);

        var group = GetGroupName(sender.Id.ToString(), recipient.Id.ToString());
        await Clients.Group(group).SendAsync("NewMessage", mapper.Map<MessageDto>(message));
    }

    private static string GetGroupName(string caller, string? other)
    {
        var stringCompare = string.CompareOrdinal(caller, other) < 0;
        return stringCompare ? $"{caller}-{other}" : $"{other}-{caller}";
    }
}
