namespace RealtimeService.Presentation.SignalR;

public class PresenceTracker
{
    private static readonly Dictionary<string, List<string>> OnlineUsers = [];

    public Task<bool> UserConnected(string userId, string connectionId)
    {
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

    public Task<bool> UserDisconnected(string userId, string connectionId)
    {
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

    public Task<string[]> GetOnlineUsers()
    {
        lock (OnlineUsers)
        {
            return Task.FromResult(OnlineUsers.Keys.ToArray());
        }
    }

    public static Task<List<string>> GetConnectionsForUser(string userId)
    {
        lock (OnlineUsers)
        {
            return Task.FromResult(OnlineUsers.TryGetValue(userId, out List<string>? value) ? value : []);
        }
    }
}
