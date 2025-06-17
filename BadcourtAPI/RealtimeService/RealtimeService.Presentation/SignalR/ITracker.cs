namespace RealtimeService.Presentation.SignalR;

public interface ITracker
{
    Task<bool> UserConnectedAsync(string userId, string connectionId);
    Task<bool> UserDisconnectedAsync(string userId, string connectionId);
    public Task<List<string>> GetConnectionsForUserAsync(string userId);
}
