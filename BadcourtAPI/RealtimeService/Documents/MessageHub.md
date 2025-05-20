# 💬 MessageHub SignalR Documentation

## Overview

`MessageHub` is a SignalR hub for managing **real-time private messaging** between authenticated users. It supports:

- Joining a private chat group between two users
- Sending messages
- Receiving message threads and new messages

---

## 🔐 Authorization

The `[Authorize]` attribute is applied to the hub class, which means **only authenticated users** with valid JWT tokens can connect and use the messaging features.

Clients must provide a valid access token when connecting.

---

## 🔌 How to Connect (Frontend)

Frontend clients must:

- Pass the `user` query parameter (the other user's ID) to identify the conversation target.
- Include a JWT token via the `accessTokenFactory`.

```javascript
import * as signalR from "@microsoft/signalr";

const otherUserId = "recipient-user-id";

const connection = new signalR.HubConnectionBuilder()
  .withUrl(`https://your-api.com/hubs/message?user=${otherUserId}`, {
    accessTokenFactory: () => getAccessToken(), // Replace with your auth logic
  })
  .withAutomaticReconnect()
  .build();

await connection.start();
```

---

## 📥 Server-to-Client Events

### 1. `"ReceiveMessageThread"`

**Description:** Triggered immediately after connecting. Sends the full message history between the logged-in user and the other user.

```javascript
connection.on("ReceiveMessageThread", messages => {
  console.log("Message history:", messages);
});
```

> `messages` is an array of `MessageDto` objects.

---

### 2. `"NewMessage"`

**Description:** Triggered in real-time when either user sends a message in the conversation.

```javascript
connection.on("NewMessage", message => {
  console.log("New message received:", message);
});
```

> `message` is a single `MessageDto` object.

---

## 📤 Client-to-Server Method

### `SendMessage(createMessageDto)`

**Description:** Used to send a new message to another user.

```javascript
await connection.invoke("SendMessage", {
  recipientId: "recipient-user-id",
  content: "Hello, this is a message!",
});
```

**Validation Rules:**

- A user **cannot send messages to themselves**.
- Both sender and recipient must be valid users (validated server-side).
- On validation failure, a `HubException` is thrown.

---

## 🛠 Server Class Summary

```csharp
[Authorize]
public class MessageHub(
    IMessageRepository messageRepository,
    IUserApiRepository userApiRepository,
    IMapper mapper
) : Hub
```

### `OnConnectedAsync()`

- Extracts the `user` from the query string.
- Joins a group (chat room) formed by the current user and the `otherUser`.
- Fetches the message thread from the repository.
- Sends the conversation to the group via `"ReceiveMessageThread"`.

### `OnDisconnectedAsync(Exception?)`

- Currently does nothing but may be extended in the future for cleanup logic.

### `SendMessage(CreateMessageDto)`

- Validates sender and recipient.
- Saves the message.
- Broadcasts the new message to the shared group via `"NewMessage"`.

---

## 🧠 Group Naming Convention

The SignalR group is uniquely and consistently named to represent a conversation between two users:

```csharp
private static string GetGroupName(string caller, string? other)
{
    var stringCompare = string.CompareOrdinal(caller, other) < 0;
    return stringCompare ? $"{caller}-{other}" : $"{other}-{caller}";
}
```

> This logic ensures both users always join the **same group** regardless of who connects first.

---

## 📌 Notes for FE Developers

- Always pass the `user` query string parameter when initiating the connection.
- Register all listeners (`.on(...)`) **before** calling `.start()`.
- Handle authentication via `accessTokenFactory`.
- Use `.withAutomaticReconnect()` to keep the connection stable.
- Use the correct hub endpoint: `/hubs/message`.
