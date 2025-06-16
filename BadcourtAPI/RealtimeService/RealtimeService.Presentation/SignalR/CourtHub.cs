using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RealtimeService.Domain.Interfaces;

namespace RealtimeService.Presentation.SignalR;

[Authorize]
public class CourtHub(ICourtRepository courtRepository) : Hub
{
    public override async Task OnConnectedAsync()
    {
        var httpContext = Context.GetHttpContext();

        var courtId = httpContext?.Request.Query["courtId"];
        if (string.IsNullOrEmpty(courtId))
        {
            throw new HubException("Court ID is required to connect to the CourtHub.");
        }

        var court = await courtRepository.GetCourtByIdAsync(courtId!)
            ?? throw new HubException($"Court with ID {courtId} not found.");

        await Groups.AddToGroupAsync(Context.ConnectionId, courtId!);

        await Clients.Caller.SendAsync("ReceiveCourt", court);
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var httpContext = Context.GetHttpContext();
        var courtId = httpContext?.Request.Query["courtId"];

        if (!string.IsNullOrEmpty(courtId))
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, courtId!);
        }

        await base.OnDisconnectedAsync(exception);
    }
}
