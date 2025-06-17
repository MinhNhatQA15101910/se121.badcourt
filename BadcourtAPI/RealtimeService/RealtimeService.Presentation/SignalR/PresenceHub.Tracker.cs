namespace RealtimeService.Presentation.SignalR;

public class PresenceHubTracker : ITracker
{
    private static readonly Dictionary<string, List<string>> OnlineUsers = [];

    public Task<bool> UserConnectedAsync(string userId, string connectionId)
    {
        Console.WriteLine($"[PresenceHubTracker] UserConnected: {userId}, ConnectionId: {connectionId}");

        var isOnline = false;
        lock (OnlineUsers)
        {
            if (OnlineUsers.ContainsKey(userId))
            {
                OnlineUsers[userId].Add(connectionId);
            }
            else
            {
                OnlineUsers.Add(userId, [connectionId]);
                isOnline = true;
            }
        }

        return Task.FromResult(isOnline);
    }

    public Task<bool> UserDisconnectedAsync(string userId, string connectionId)
    {
        Console.WriteLine($"[PresenceHubTracker] UserDisconnected: {userId}, ConnectionId: {connectionId}");

        var isOffline = false;
        lock (OnlineUsers)
        {
            if (!OnlineUsers.ContainsKey(userId)) return Task.FromResult(isOffline);

            OnlineUsers[userId].Remove(connectionId);

            if (OnlineUsers[userId].Count == 0)
            {
                OnlineUsers.Remove(userId);
                isOffline = true;
            }
        }

        return Task.FromResult(isOffline);
    }

    public Task<string[]> GetOnlineUsersAsync()
    {
        lock (OnlineUsers)
        {
            return Task.FromResult(OnlineUsers.Keys.ToArray());
        }
    }

    public Task<List<string>> GetConnectionsForUserAsync(string userId)
    {
        lock (OnlineUsers)
        {
            return Task.FromResult(OnlineUsers.TryGetValue(userId, out List<string>? value) ? value : []);
        }
    }
}
