import * as signalR from "@microsoft/signalr"
import type {
  PresenceCallbacks,
  MessageCallbacks,
  GroupCallbacks,
  SignalRMessageThread,
  SignalRMessage,
  SignalRGroup,
  SignalRGroupList,
  UserDto,
} from "@/lib/types"

// Get API URL from environment variables with fallback
const API_URL = process.env.NEXT_SIGNALR_API_URL || "http://localhost:7000"

// Define hub URLs
const PRESENCE_HUB_URL = `${API_URL}/hubs/presence`
const MESSAGE_HUB_URL = `${API_URL}/hubs/message`
const GROUP_HUB_URL = `${API_URL}/hubs/group`

// Store connections for reuse
let presenceConnection: signalR.HubConnection | null = null
let messageConnection: signalR.HubConnection | null = null
let groupConnection: signalR.HubConnection | null = null

// Store callbacks for event handling
let presenceCallbacks: PresenceCallbacks = {}
let messageCallbacks: MessageCallbacks = {}
let groupCallbacks: GroupCallbacks = {}

// Variables to track connection status
let isPresenceConnected = false
let isMessageConnected = false
let isGroupConnected = false

/**
 * Initialize connection with PresenceHub
 */
export async function startPresenceConnection(
  token: string,
  callbacks: PresenceCallbacks = {},
): Promise<signalR.HubConnection | null> {
    console.log(token);

  try {
    presenceCallbacks = callbacks

    if (presenceConnection && presenceConnection.state === signalR.HubConnectionState.Connected) {
      return presenceConnection
    }

    if (!token) {
      console.error("No authentication token available")
      return null
    }

    presenceConnection = new signalR.HubConnectionBuilder()
      .withUrl(PRESENCE_HUB_URL, {
        accessTokenFactory: () => token,
      })
      .withAutomaticReconnect([0, 2000, 5000, 10000, 20000])
      .configureLogging(signalR.LogLevel.Information)
      .build()

    // Register presence events
    presenceConnection.on("UserIsOnline", (userId: string) => {
      console.log(`[SignalR] User ${userId} is online`)
      presenceCallbacks.onUserOnline?.(userId)
    })

    presenceConnection.on("UserIsOffline", (userId: string) => {
      console.log(`[SignalR] User ${userId} is offline`)
      presenceCallbacks.onUserOffline?.(userId)
    })

    presenceConnection.on("GetOnlineUsers", (users: string[]) => {
      console.log("[SignalR] Online users list:", users)
      presenceCallbacks.onOnlineUsers?.(users)
    })

    // Connection events
    presenceConnection.onreconnecting((error) => {
      console.log(`[SignalR] Reconnecting to PresenceHub: ${error}`)
      isPresenceConnected = false
    })

    presenceConnection.onreconnected((connectionId) => {
      console.log(`[SignalR] Reconnected to PresenceHub. ID: ${connectionId}`)
      isPresenceConnected = true
    })

    presenceConnection.onclose((error) => {
      console.log(`[SignalR] PresenceHub connection closed: ${error}`)
      isPresenceConnected = false
    })

    await presenceConnection.start()
    console.log("[SignalR] Connected to PresenceHub")
    isPresenceConnected = true

    return presenceConnection
  } catch (error) {
    console.error("[SignalR] Error connecting to PresenceHub:", error)
    isPresenceConnected = false
    return null
  }
}

/**
 * Stop presence connection
 */
export async function stopPresenceConnection(): Promise<void> {
  try {
    if (presenceConnection) {
      await presenceConnection.stop()
      presenceConnection = null
      isPresenceConnected = false
      presenceCallbacks = {}
      console.log("[SignalR] PresenceHub connection stopped")
    }
  } catch (error) {
    console.error("[SignalR] Error stopping PresenceHub connection:", error)
  }
}

/**
 * Initialize connection with MessageHub
 */
export async function startMessageConnection(
  token: string,
  callbacks: MessageCallbacks = {},
): Promise<signalR.HubConnection | null> {
  try {
    messageCallbacks = callbacks

    if (messageConnection && messageConnection.state === signalR.HubConnectionState.Connected) {
      return messageConnection
    }

    if (!token) {
      console.error("No authentication token available")
      return null
    }

    messageConnection = new signalR.HubConnectionBuilder()
      .withUrl(MESSAGE_HUB_URL, {
        accessTokenFactory: () => token,
      })
      .withAutomaticReconnect([0, 2000, 5000, 10000, 20000])
      .configureLogging(signalR.LogLevel.Information)
      .build()

    // Register message events
    messageConnection.on("NewMessage", (message: SignalRMessage) => {
      console.log("[SignalR] New message received:", message)
      messageCallbacks.onNewMessage?.(message)
    })

    messageConnection.on("MessageRead", (messageId: string, userId: string) => {
      console.log(`[SignalR] Message ${messageId} read by user ${userId}`)
      messageCallbacks.onMessageRead?.(messageId, userId)
    })

    // Connection events
    messageConnection.onreconnecting((error) => {
      console.log(`[SignalR] Reconnecting to MessageHub: ${error}`)
      isMessageConnected = false
    })

    messageConnection.onreconnected((connectionId) => {
      console.log(`[SignalR] Reconnected to MessageHub. ID: ${connectionId}`)
      isMessageConnected = true
    })

    messageConnection.onclose((error) => {
      console.log(`[SignalR] MessageHub connection closed: ${error}`)
      isMessageConnected = false
    })

    await messageConnection.start()
    console.log("[SignalR] Connected to MessageHub")
    isMessageConnected = true

    return messageConnection
  } catch (error) {
    console.error("[SignalR] Error connecting to MessageHub:", error)
    isMessageConnected = false
    return null
  }
}

/**
 * Stop message connection
 */
export async function stopMessageConnection(): Promise<void> {
  try {
    if (messageConnection) {
      await messageConnection.stop()
      messageConnection = null
      isMessageConnected = false
      messageCallbacks = {}
      console.log("[SignalR] MessageHub connection stopped")
    }
  } catch (error) {
    console.error("[SignalR] Error stopping MessageHub connection:", error)
  }
}

/**
 * Initialize connection with GroupHub
 */
export async function startGroupConnection(
  token: string,
  callbacks: GroupCallbacks = {},
): Promise<signalR.HubConnection | null> {
  try {
    groupCallbacks = callbacks

    if (groupConnection && groupConnection.state === signalR.HubConnectionState.Connected) {
      return groupConnection
    }

    if (!token) {
      console.error("No authentication token available")
      return null
    }

    groupConnection = new signalR.HubConnectionBuilder()
      .withUrl(GROUP_HUB_URL, {
        accessTokenFactory: () => token,
      })
      .withAutomaticReconnect([0, 2000, 5000, 10000, 20000])
      .configureLogging(signalR.LogLevel.Information)
      .build()

    // Register group events with pagination support
    groupConnection.on("ReceiveGroups", (groupList: SignalRGroupList) => {
      console.log("[SignalR] Received groups with pagination:", groupList)
      groupCallbacks.onReceiveGroups?.(groupList)
    })

    groupConnection.on("ReceiveMessageThread", (messageThread: SignalRMessageThread) => {
      console.log("[SignalR] Received message thread with pagination:", messageThread)
      messageCallbacks.onReceiveMessageThread?.(messageThread)
    })

    groupConnection.on("JoinedGroup", (group: SignalRGroup) => {
      console.log("[SignalR] Joined group:", group)
      groupCallbacks.onJoinedGroup?.(group)
    })

    groupConnection.on("LeftGroup", (groupId: string) => {
      console.log("[SignalR] Left group:", groupId)
      groupCallbacks.onLeftGroup?.(groupId)
    })

    groupConnection.on("GroupUpdated", (group: SignalRGroup) => {
      console.log("[SignalR] Group updated:", group)
      groupCallbacks.onGroupUpdated?.(group)
    })

    groupConnection.on("UserJoinedGroup", (groupId: string, user: UserDto) => {
      console.log(`[SignalR] User ${user.username} joined group ${groupId}`)
      groupCallbacks.onUserJoinedGroup?.(groupId, user)
    })

    groupConnection.on("UserLeftGroup", (groupId: string, userId: string) => {
      console.log(`[SignalR] User ${userId} left group ${groupId}`)
      groupCallbacks.onUserLeftGroup?.(groupId, userId)
    })

    // Connection events
    groupConnection.onreconnecting((error) => {
      console.log(`[SignalR] Reconnecting to GroupHub: ${error}`)
      isGroupConnected = false
    })

    groupConnection.onreconnected((connectionId) => {
      console.log(`[SignalR] Reconnected to GroupHub. ID: ${connectionId}`)
      isGroupConnected = true
    })

    groupConnection.onclose((error) => {
      console.log(`[SignalR] GroupHub connection closed: ${error}`)
      isGroupConnected = false
    })

    await groupConnection.start()
    console.log("[SignalR] Connected to GroupHub")
    isGroupConnected = true

    return groupConnection
  } catch (error) {
    console.error("[SignalR] Error connecting to GroupHub:", error)
    isGroupConnected = false
    return null
  }
}

/**
 * Stop group connection
 */
export async function stopGroupConnection(): Promise<void> {
  try {
    if (groupConnection) {
      await groupConnection.stop()
      groupConnection = null
      isGroupConnected = false
      groupCallbacks = {}
      console.log("[SignalR] GroupHub connection stopped")
    }
  } catch (error) {
    console.error("[SignalR] Error stopping GroupHub connection:", error)
  }
}

/**
 * Get groups with pagination
 */
export async function getGroups(page = 1, pageSize = 20): Promise<boolean> {
  try {
    if (!groupConnection || groupConnection.state !== signalR.HubConnectionState.Connected) {
      console.error("[SignalR] Cannot get groups: No connection to GroupHub")
      return false
    }

    await groupConnection.invoke("GetGroups", page, pageSize)
    console.log(`[SignalR] Requested groups - Page: ${page}, PageSize: ${pageSize}`)
    return true
  } catch (error) {
    console.error(`[SignalR] Error getting groups:`, error)
    return false
  }
}

/**
 * Get message thread for a group with pagination
 */
export async function getMessageThread(groupId: string, page = 1, pageSize = 50): Promise<boolean> {
  try {
    if (!groupConnection || groupConnection.state !== signalR.HubConnectionState.Connected) {
      console.error("[SignalR] Cannot get message thread: No connection to GroupHub")
      return false
    }

    await groupConnection.invoke("GetMessageThread", groupId, page, pageSize)
    console.log(`[SignalR] Requested message thread for group ${groupId} - Page: ${page}, PageSize: ${pageSize}`)
    return true
  } catch (error) {
    console.error(`[SignalR] Error getting message thread for group ${groupId}:`, error)
    return false
  }
}

/**
 * Load more messages for a group (next page)
 */
export async function loadMoreMessages(groupId: string, currentPage: number, pageSize = 50): Promise<boolean> {
  const nextPage = currentPage + 1
  return await getMessageThread(groupId, nextPage, pageSize)
}

/**
 * Load previous messages for a group (previous page)
 */
export async function loadPreviousMessages(groupId: string, currentPage: number, pageSize = 50): Promise<boolean> {
  if (currentPage <= 1) return false
  const previousPage = currentPage - 1
  return await getMessageThread(groupId, previousPage, pageSize)
}

/**
 * Join a group
 */
export async function joinGroup(groupId: string): Promise<boolean> {
  try {
    if (!groupConnection || groupConnection.state !== signalR.HubConnectionState.Connected) {
      console.error("[SignalR] Cannot join group: No connection to GroupHub")
      return false
    }

    await groupConnection.invoke("JoinGroup", groupId)
    console.log(`[SignalR] Joined group ${groupId}`)
    return true
  } catch (error) {
    console.error(`[SignalR] Error joining group ${groupId}:`, error)
    return false
  }
}

/**
 * Leave a group
 */
export async function leaveGroup(groupId: string): Promise<boolean> {
  try {
    if (!groupConnection || groupConnection.state !== signalR.HubConnectionState.Connected) {
      console.error("[SignalR] Cannot leave group: No connection to GroupHub")
      return false
    }

    await groupConnection.invoke("LeaveGroup", groupId)
    console.log(`[SignalR] Left group ${groupId}`)
    return true
  } catch (error) {
    console.error(`[SignalR] Error leaving group ${groupId}:`, error)
    return false
  }
}

/**
 * Send message to group
 */
export async function sendMessageToGroup(groupId: string, content: string, resources?: File[]): Promise<boolean> {
  try {
    if (!groupConnection || groupConnection.state !== signalR.HubConnectionState.Connected) {
      console.error("[SignalR] Cannot send message: No connection to GroupHub")
      return false
    }

    const messageData = {
      groupId,
      content,
      resources: resources || [],
    }

    await groupConnection.invoke("SendMessageToGroup", messageData)
    console.log(`[SignalR] Message sent to group ${groupId}`)
    return true
  } catch (error) {
    console.error(`[SignalR] Error sending message to group ${groupId}:`, error)
    return false
  }
}

/**
 * Send direct message to user
 */
export async function sendDirectMessage(receiverId: string, content: string, resources?: File[]): Promise<boolean> {
  try {
    if (!messageConnection || messageConnection.state !== signalR.HubConnectionState.Connected) {
      console.error("[SignalR] Cannot send message: No connection to MessageHub")
      return false
    }

    const messageData = {
      receiverId,
      content,
      resources: resources || [],
    }

    await messageConnection.invoke("SendDirectMessage", messageData)
    console.log(`[SignalR] Direct message sent to user ${receiverId}`)
    return true
  } catch (error) {
    console.error(`[SignalR] Error sending direct message to user ${receiverId}:`, error)
    return false
  }
}

/**
 * Mark message as read
 */
export async function markMessageAsRead(messageId: string): Promise<boolean> {
  try {
    if (!messageConnection || messageConnection.state !== signalR.HubConnectionState.Connected) {
      console.error("[SignalR] Cannot mark message as read: No connection to MessageHub")
      return false
    }

    await messageConnection.invoke("MarkMessageAsRead", messageId)
    console.log(`[SignalR] Message ${messageId} marked as read`)
    return true
  } catch (error) {
    console.error(`[SignalR] Error marking message ${messageId} as read:`, error)
    return false
  }
}

/**
 * Stop all connections
 */
export async function stopAllConnections(): Promise<void> {
  try {
    const promises = []

    if (presenceConnection) {
      promises.push(stopPresenceConnection())
    }

    if (messageConnection) {
      promises.push(stopMessageConnection())
    }

    if (groupConnection) {
      promises.push(stopGroupConnection())
    }

    await Promise.all(promises)

    console.log("[SignalR] All connections stopped")
  } catch (error) {
    console.error("[SignalR] Error stopping connections:", error)
  }
}

/**
 * Connection state getters
 */
export function getConnectionStates() {
  return {
    presence: isPresenceConnected,
    message: isMessageConnected,
    group: isGroupConnected,
  }
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

/**
 * Get individual connections (for advanced usage)
 */
export function getPresenceConnection(): signalR.HubConnection | null {
  return presenceConnection
}

export function getMessageConnection(): signalR.HubConnection | null {
  return messageConnection
}

export function getGroupConnection(): signalR.HubConnection | null {
  return groupConnection
}
