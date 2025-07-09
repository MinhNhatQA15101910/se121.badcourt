import * as signalR from "@microsoft/signalr"
import type {
  PresenceCallbacks,
  MessageCallbacks,
  GroupCallbacks,
  SignalRMessageThread,
  SignalRMessage,
  SignalRGroupList,
  SignalRGroup,
} from "@/lib/types"

// Get API URL from environment variables with fallback
const API_URL = process.env.NEXT_PUBLIC_SIGNALR_API_URL || "http://localhost:7000"

// Define hub URLs
const PRESENCE_HUB_URL = `${API_URL}/hubs/presence`
const MESSAGE_HUB_URL = `${API_URL}/hubs/message`
const GROUP_HUB_URL = `${API_URL}/hubs/group`

// Global connections for Presence and Group (persistent throughout app lifecycle)
let presenceConnection: signalR.HubConnection | null = null
let groupConnection: signalR.HubConnection | null = null

// Local connection for Message (only when in message page)
let messageConnection: signalR.HubConnection | null = null

// Store callbacks
let presenceCallbacks: PresenceCallbacks = {}
let messageCallbacks: MessageCallbacks = {}
let groupCallbacks: GroupCallbacks = {}

// Connection status
let isPresenceConnected = false
let isMessageConnected = false
let isGroupConnected = false

// Track current message connection user
let currentMessageUserId: string | null = null
let isConnecting = false

// Limited retry configuration
const RETRY_DELAYS = [0, 2000, 5000, 10000, 20000]
const MAX_RETRY_ATTEMPTS = 4

/**
 * Create connection with limited retry
 */
function createConnection(hubUrl: string, token: string): signalR.HubConnection {
  return new signalR.HubConnectionBuilder()
    .withUrl(hubUrl, {
      accessTokenFactory: () => token,
      skipNegotiation: true,
      transport: signalR.HttpTransportType.WebSockets,
    })
    .withAutomaticReconnect({
      nextRetryDelayInMilliseconds: (retryContext) => {
        if (retryContext.previousRetryCount >= MAX_RETRY_ATTEMPTS) {
          console.log(`[SignalR] Max retry attempts reached. Stopping reconnection.`)
          return null
        }
        return RETRY_DELAYS[retryContext.previousRetryCount] || 30000
      },
    })
    .configureLogging(signalR.LogLevel.Information)
    .build()
}

/**
 * GLOBAL: Start PresenceHub connection (persistent)
 */
export async function startPresenceConnection(
  token: string,
  callbacks: PresenceCallbacks = {},
): Promise<signalR.HubConnection | null> {
  try {
    presenceCallbacks = callbacks

    if (presenceConnection && presenceConnection.state === signalR.HubConnectionState.Connected) {
      console.log("[SignalR] PresenceHub already connected")
      return presenceConnection
    }

    if (presenceConnection) {
      await stopPresenceConnection()
    }

    console.log("[SignalR] Creating GLOBAL PresenceHub connection...")
    presenceConnection = createConnection(PRESENCE_HUB_URL, token)

    // Register events
    presenceConnection.on("UserIsOnline", (userId: string) => {
      presenceCallbacks.onUserOnline?.(userId)
    })

    presenceConnection.on("UserIsOffline", (userId: string) => {
      presenceCallbacks.onUserOffline?.(userId)
    })

    presenceConnection.on("GetOnlineUsers", (users: string[]) => {
      presenceCallbacks.onOnlineUsers?.(users)
    })

    presenceConnection.onreconnected(() => {
      isPresenceConnected = true
    })

    presenceConnection.onclose(() => {
      isPresenceConnected = false
    })

    await presenceConnection.start()
    console.log("[SignalR] GLOBAL PresenceHub connected successfully")
    isPresenceConnected = true

    return presenceConnection
  } catch (error) {
    console.error("[SignalR] Error connecting to PresenceHub:", error)
    isPresenceConnected = false
    return null
  }
}

/**
 * GLOBAL: Start GroupHub connection (persistent)
 */
export async function startGroupConnection(
  token: string,
  callbacks: GroupCallbacks = {},
): Promise<signalR.HubConnection | null> {
  try {
    groupCallbacks = callbacks

    if (groupConnection && groupConnection.state === signalR.HubConnectionState.Connected) {
      console.log("[SignalR] GroupHub already connected")
      return groupConnection
    }

    if (groupConnection) {
      await stopGroupConnection()
    }

    console.log("[SignalR] Creating GLOBAL GroupHub connection...")
    groupConnection = createConnection(GROUP_HUB_URL, token)

    // Register events
    groupConnection.on("ReceiveGroups", (groupList: SignalRGroupList) => {
      groupCallbacks.onReceiveGroups?.(groupList)
    })

    groupConnection.on("ReceiveNumberOfUnreadMessages", (count: number) => {
      console.log("[SignalR] Unread messages count:", count)
    })

    groupConnection.on("NewMessageReceived", (groupDto: SignalRGroup) => {
      console.log("[SignalR] NewMessageReceived event:", groupDto)
      groupCallbacks.onNewMessageReceived?.(groupDto)
    })

    // Trong startGroupConnection function, thêm event listener cho group mới được tạo:
    groupConnection.on("GroupCreated", (newGroup: SignalRGroup) => {
      console.log("[SignalR] New group created:", newGroup)
      groupCallbacks.onGroupCreated?.(newGroup)
    })

    groupConnection.onreconnected(() => {
      isGroupConnected = true
    })

    groupConnection.onclose(() => {
      isGroupConnected = false
    })

    await groupConnection.start()
    console.log("[SignalR] GLOBAL GroupHub connected successfully")
    isGroupConnected = true

    return groupConnection
  } catch (error) {
    console.error("[SignalR] Error connecting to GroupHub:", error)
    isGroupConnected = false
    return null
  }
}

/**
 * LOCAL: Start MessageHub connection (only for message page)
 */
export async function startMessageConnection(
  token: string,
  otherUserId: string,
  callbacks: MessageCallbacks = {},
): Promise<signalR.HubConnection | null> {
  // Prevent concurrent connections
  if (isConnecting) {
    console.log("[SignalR] Already connecting, waiting...")
    // Wait for current connection attempt to finish
    let attempts = 0
    while (isConnecting && attempts < 20) {
      await new Promise((resolve) => setTimeout(resolve, 250))
      attempts++
    }
  }

  try {
    isConnecting = true
    messageCallbacks = callbacks

    // If already connected to the same user, return existing connection
    if (
      messageConnection &&
      messageConnection.state === signalR.HubConnectionState.Connected &&
      currentMessageUserId === otherUserId
    ) {
      console.log(`[SignalR] Already connected to MessageHub for user: ${otherUserId}`)
      return messageConnection
    }

    // Stop existing connection if connecting to different user
    if (messageConnection && currentMessageUserId !== otherUserId) {
      console.log(
        `[SignalR] Stopping existing MessageHub connection (current: ${currentMessageUserId}, new: ${otherUserId})`,
      )
      await stopMessageConnection()
      // Add delay to ensure connection is fully closed
      await new Promise((resolve) => setTimeout(resolve, 1000))
    }

    console.log(`[SignalR] Creating LOCAL MessageHub connection with user: ${otherUserId}`)
    currentMessageUserId = otherUserId

    messageConnection = new signalR.HubConnectionBuilder()
      .withUrl(`${MESSAGE_HUB_URL}?user=${otherUserId}`, {
        accessTokenFactory: () => token,
        skipNegotiation: true,
        transport: signalR.HttpTransportType.WebSockets,
      })
      .withAutomaticReconnect(RETRY_DELAYS)
      .configureLogging(signalR.LogLevel.Information)
      .build()

    // Register events
    messageConnection.on("ReceiveMessageThread", (messageThread: SignalRMessageThread) => {
      console.log("[SignalR] ReceiveMessageThread event received:", messageThread)
      messageCallbacks.onReceiveMessageThread?.(messageThread)
    })

    messageConnection.on("NewMessage", (message: SignalRMessage) => {
      console.log("[SignalR] NewMessage event received:", message)
      messageCallbacks.onNewMessage?.(message)
    })

    messageConnection.onreconnected(() => {
      isMessageConnected = true
      console.log("[SignalR] MessageHub reconnected")
    })

    messageConnection.onclose((error) => {
      if (error) {
        console.error("[SignalR] MessageHub connection closed with error:", error)
      }
      isMessageConnected = false
      currentMessageUserId = null
      console.log("[SignalR] MessageHub connection closed")
    })

    // Set timeout for connection
    const connectionTimeout = new Promise((_, reject) => {
      setTimeout(() => reject(new Error("Connection timeout")), 10000)
    })

    await Promise.race([messageConnection.start(), connectionTimeout])

    console.log("[SignalR] LOCAL MessageHub connected successfully")
    isMessageConnected = true

    return messageConnection
  } catch (error) {
    console.error("[SignalR] Error connecting to MessageHub:", error)
    isMessageConnected = false
    currentMessageUserId = null

    // Clean up failed connection
    if (messageConnection) {
      try {
        await messageConnection.stop()
      } catch (stopError) {
        console.error("[SignalR] Error stopping failed connection:", stopError)
      }
      messageConnection = null
    }

    return null
  } finally {
    isConnecting = false
  }
}

/**
 * Stop connections
 */
export async function stopPresenceConnection(): Promise<void> {
  if (presenceConnection) {
    try {
      if (presenceConnection.state !== signalR.HubConnectionState.Disconnected) {
        await presenceConnection.stop()
      }
    } catch (error) {
      console.error("[SignalR] Error stopping PresenceHub:", error)
    } finally {
      presenceConnection = null
      isPresenceConnected = false
      console.log("[SignalR] GLOBAL PresenceHub disconnected")
    }
  }
}

export async function stopGroupConnection(): Promise<void> {
  if (groupConnection) {
    try {
      if (groupConnection.state !== signalR.HubConnectionState.Disconnected) {
        await groupConnection.stop()
      }
    } catch (error) {
      console.error("[SignalR] Error stopping GroupHub:", error)
    } finally {
      groupConnection = null
      isGroupConnected = false
      console.log("[SignalR] GLOBAL GroupHub disconnected")
    }
  }
}

export async function stopMessageConnection(): Promise<void> {
  if (messageConnection) {
    try {
      if (messageConnection.state !== signalR.HubConnectionState.Disconnected) {
        await messageConnection.stop()
      }
    } catch (error) {
      console.error("[SignalR] Error stopping MessageHub:", error)
    } finally {
      messageConnection = null
      isMessageConnected = false
      currentMessageUserId = null
      console.log("[SignalR] LOCAL MessageHub disconnected")
    }
  }
}

/**
 * Connection states
 */
export function getConnectionStates() {
  return {
    presence: isPresenceConnected,
    message: isMessageConnected,
    group: isGroupConnected,
  }
}

/**
 * Refresh groups (reconnect GroupHub)
 */
export async function refreshGroups(token: string): Promise<boolean> {
  try {
    if (groupConnection) {
      await stopGroupConnection()
      await new Promise((resolve) => setTimeout(resolve, 1000))
    }
    const connection = await startGroupConnection(token, groupCallbacks)
    return connection !== null
  } catch (error) {
    console.error("[SignalR] Error refreshing groups:", error)
    return false
  }
}

/**
 * Connect to user for direct messaging
 */
export async function connectToUser(
  token: string,
  otherUserId: string,
  callbacks: MessageCallbacks = {},
): Promise<boolean> {
  const connection = await startMessageConnection(token, otherUserId, callbacks)
  return connection !== null
}

// Placeholder functions for compatibility
export async function getGroups(): Promise<boolean> {
  return isGroupConnected
}

export async function getMessageThread(): Promise<boolean> {
  return isMessageConnected
}

export async function loadMoreMessages(): Promise<boolean> {
  return false
}

export async function loadPreviousMessages(): Promise<boolean> {
  return false
}

export async function joinGroup(): Promise<boolean> {
  return false
}

export async function leaveGroup(): Promise<boolean> {
  return false
}

export async function sendMessageToGroup(): Promise<boolean> {
  return false
}

export async function sendDirectMessage(): Promise<boolean> {
  return false
}

export async function markMessageAsRead(): Promise<boolean> {
  return false
}

export function isPresenceHubConnected(): boolean {
  return isPresenceConnected
}

export function isMessageHubConnected(): boolean {
  return isMessageConnected
}

export function isGroupHubConnected(): boolean {
  return isGroupConnected
}
