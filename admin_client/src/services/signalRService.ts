import * as signalR from "@microsoft/signalr"
import { getSession } from "next-auth/react"
import type { PresenceCallbacks, MessageCallbacks, SignalRMessageThread, SignalRMessage } from "@/lib/types"

// Lấy API URL từ biến môi trường
const API_URL = "http://localhost:7000"

// Định nghĩa các URL của hub
const PRESENCE_HUB_URL = `${API_URL}/hubs/presence`
const MESSAGE_HUB_URL = `${API_URL}/hubs/message`

// Lưu trữ các kết nối để tái sử dụng
let presenceConnection: signalR.HubConnection | null = null
const messageConnections: Map<string, signalR.HubConnection> = new Map()

// Lưu trữ các callback để xử lý sự kiện
let presenceCallbacks: PresenceCallbacks = {}
const messageCallbacksMap: Map<string, MessageCallbacks> = new Map()

/**
 * Khởi tạo kết nối với PresenceHub
 */
export async function startPresenceConnection(
  callbacks: PresenceCallbacks = {},
): Promise<signalR.HubConnection | null> {
  try {
    // Lưu trữ callbacks
    presenceCallbacks = callbacks

    // Nếu đã có kết nối và đang hoạt động, trả về kết nối đó
    if (presenceConnection && presenceConnection.state === signalR.HubConnectionState.Connected) {
      return presenceConnection
    }

    // Lấy session để có token
    const session = await getSession()
    if (!session?.token) {
      console.error("No authentication token available")
      return null
    }

    // Tạo kết nối mới
    presenceConnection = new signalR.HubConnectionBuilder()
      .withUrl(PRESENCE_HUB_URL, {
        accessTokenFactory: () => session.token,
      })
      .withAutomaticReconnect([0, 2000, 5000, 10000, 20000]) // Thử kết nối lại với thời gian tăng dần
      .configureLogging(signalR.LogLevel.Information)
      .build()

    // Đăng ký các sự kiện
    presenceConnection.on("UserIsOnline", (userId: string) => {
      console.log(`[SignalR] Người dùng ${userId} đang trực tuyến`)
      presenceCallbacks.onUserOnline?.(userId)
    })

    presenceConnection.on("UserIsOffline", (userId: string) => {
      console.log(`[SignalR] Người dùng ${userId} đã ngoại tuyến`)
      presenceCallbacks.onUserOffline?.(userId)
    })

    presenceConnection.on("GetOnlineUsers", (users: string[]) => {
      console.log("[SignalR] Danh sách người dùng trực tuyến:", users)
      presenceCallbacks.onOnlineUsers?.(users)
    })

    // Đăng ký các sự kiện kết nối
    presenceConnection.onreconnecting((error) => {
      console.log(`[SignalR] Đang kết nối lại PresenceHub: ${error}`)
    })

    presenceConnection.onreconnected((connectionId) => {
      console.log(`[SignalR] Đã kết nối lại PresenceHub. ID: ${connectionId}`)
    })

    presenceConnection.onclose((error) => {
      console.log(`[SignalR] Kết nối PresenceHub đã đóng: ${error}`)
    })

    // Bắt đầu kết nối
    await presenceConnection.start()
    console.log("[SignalR] Đã kết nối với PresenceHub")

    return presenceConnection
  } catch (error) {
    console.error("[SignalR] Lỗi khi kết nối với PresenceHub:", error)
    return null
  }
}

/**
 * Dừng kết nối với PresenceHub
 */
export async function stopPresenceConnection(): Promise<void> {
  if (presenceConnection) {
    try {
      await presenceConnection.stop()
      presenceConnection = null
      console.log("[SignalR] Đã ngắt kết nối với PresenceHub")
    } catch (error) {
      console.error("[SignalR] Lỗi khi ngắt kết nối với PresenceHub:", error)
    }
  }
}

/**
 * Khởi tạo kết nối với MessageHub
 * @param otherUserId ID của người dùng khác trong cuộc trò chuyện
 * @param callbacks Các callback để xử lý sự kiện
 */
export async function startMessageConnection(
  otherUserId: string,
  callbacks: MessageCallbacks = {},
): Promise<signalR.HubConnection | null> {
  try {
    // Lưu trữ callbacks
    messageCallbacksMap.set(otherUserId, callbacks)

    // Kiểm tra xem đã có kết nối chưa
    const existingConnection = messageConnections.get(otherUserId)
    if (existingConnection && existingConnection.state === signalR.HubConnectionState.Connected) {
      return existingConnection
    }

    // Lấy session để có token
    const session = await getSession()
    if (!session?.token) {
      console.error("No authentication token available")
      return null
    }

    // Tạo kết nối mới
    const connection = new signalR.HubConnectionBuilder()
      .withUrl(`${MESSAGE_HUB_URL}?user=${otherUserId}`, {
        accessTokenFactory: () => session.token,
      })
      .withAutomaticReconnect([0, 2000, 5000, 10000, 20000])
      .configureLogging(signalR.LogLevel.Information)
      .build()

    // Đăng ký các sự kiện
    connection.on("ReceiveMessageThread", (messages: SignalRMessageThread) => {
      console.log("[SignalR] Nhận chuỗi tin nhắn:", messages)
      callbacks.onReceiveMessageThread?.(messages)
    })

    connection.on("NewMessage", (message: SignalRMessage) => {
      console.log("[SignalR] Tin nhắn mới:", message)
      callbacks.onNewMessage?.(message)
    })

    // Đăng ký các sự kiện kết nối
    connection.onreconnecting((error) => {
      console.log(`[SignalR] Đang kết nối lại MessageHub (${otherUserId}): ${error}`)
    })

    connection.onreconnected((connectionId) => {
      console.log(`[SignalR] Đã kết nối lại MessageHub (${otherUserId}). ID: ${connectionId}`)
    })

    connection.onclose((error) => {
      console.log(`[SignalR] Kết nối MessageHub (${otherUserId}) đã đóng: ${error}`)
      // Xóa kết nối khỏi map
      messageConnections.delete(otherUserId)
    })

    // Bắt đầu kết nối
    await connection.start()
    console.log(`[SignalR] Đã kết nối với MessageHub (${otherUserId})`)

    // Lưu kết nối vào map
    messageConnections.set(otherUserId, connection)

    return connection
  } catch (error) {
    console.error(`[SignalR] Lỗi khi kết nối với MessageHub (${otherUserId}):`, error)
    return null
  }
}

/**
 * Dừng kết nối với MessageHub
 * @param otherUserId ID của người dùng khác trong cuộc trò chuyện
 */
export async function stopMessageConnection(otherUserId: string): Promise<void> {
  const connection = messageConnections.get(otherUserId)
  if (connection) {
    try {
      await connection.stop()
      messageConnections.delete(otherUserId)
      messageCallbacksMap.delete(otherUserId)
      console.log(`[SignalR] Đã ngắt kết nối với MessageHub (${otherUserId})`)
    } catch (error) {
      console.error(`[SignalR] Lỗi khi ngắt kết nối với MessageHub (${otherUserId}):`, error)
    }
  }
}

/**
 * Gửi tin nhắn đến người dùng khác
 * @param otherUserId ID của người dùng nhận tin nhắn
 * @param content Nội dung tin nhắn
 */
export async function sendMessage(otherUserId: string, content: string): Promise<boolean> {
  try {
    const connection = messageConnections.get(otherUserId)
    if (!connection || connection.state !== signalR.HubConnectionState.Connected) {
      console.error(`[SignalR] Không thể gửi tin nhắn: Không có kết nối với MessageHub (${otherUserId})`)
      return false
    }

    await connection.invoke("SendMessage", {
      recipientId: otherUserId,
      content: content,
    })

    console.log(`[SignalR] Đã gửi tin nhắn đến ${otherUserId}`)
    return true
  } catch (error) {
    console.error(`[SignalR] Lỗi khi gửi tin nhắn đến ${otherUserId}:`, error)
    return false
  }
}

/**
 * Dừng tất cả các kết nối SignalR
 */
export async function stopAllConnections(): Promise<void> {
  try {
    // Dừng kết nối PresenceHub
    if (presenceConnection) {
      await presenceConnection.stop()
      presenceConnection = null
    }

    // Dừng tất cả các kết nối MessageHub
    for (const [userId, connection] of messageConnections.entries()) {
      await connection.stop()
      console.log(`[SignalR] Đã ngắt kết nối với MessageHub (${userId})`)
    }

    // Xóa tất cả các kết nối và callback
    messageConnections.clear()
    messageCallbacksMap.clear()
    presenceCallbacks = {}

    console.log("[SignalR] Đã ngắt tất cả các kết nối")
  } catch (error) {
    console.error("[SignalR] Lỗi khi ngắt tất cả các kết nối:", error)
  }
}
