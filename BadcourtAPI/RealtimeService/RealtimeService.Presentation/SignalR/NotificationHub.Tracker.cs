namespace RealtimeService.Presentation.SignalR;

public class NotificationHubTracker : ITracker
{
    private static readonly Dictionary<string, List<string>> OnlineUsers = [];

    public Task<bool> UserConnectedAsync(string userId, string connectionId)
    {
        Console.WriteLine($"[NotificationHubTracker] UserConnected: {userId}, ConnectionId: {connectionId}");

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
        Console.WriteLine($"[NotificationHubTracker] UserDisconnected: {userId}, ConnectionId: {connectionId}");

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

    public Task<List<string>> GetConnectionsForUserAsync(string userId)
    {
        lock (OnlineUsers)
        {
            return Task.FromResult(OnlineUsers.TryGetValue(userId, out List<string>? value) ? value : []);
        }
    }
}
