using Microsoft.AspNetCore.SignalR;
using RealtimeService.Application.ApiRepositories;

namespace RealtimeService.Presentation.SignalR;

public class CourtHub(ICourtApiRepository courtApiRepository) : Hub
{
    public override async Task OnConnectedAsync()
    {
        var httpContext = Context.GetHttpContext();

        var courtId = httpContext?.Request.Query["courtId"];
        if (string.IsNullOrEmpty(courtId))
        {
            throw new HubException("Court ID is required to connect to the CourtHub.");
        }

        var court = await courtApiRepository.GetCourtByIdAsync(courtId!)
            ?? throw new HubException($"Court with ID {courtId} not found.");

        await Clients.Caller.SendAsync("ReceiveCourt", court);
    }
}
