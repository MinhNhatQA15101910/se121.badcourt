"use client"

import { createContext, useContext, useEffect, useState, type ReactNode } from "react"
import { useSession } from "next-auth/react"
import {
  startPresenceConnection,
  startMessageConnection,
  stopMessageConnection,
  stopAllConnections,
  sendMessage,
} from "@/services/signalRService"
import type { SignalRMessage, SignalRMessageThread } from "@/lib/types"

interface SignalRContextType {
  onlineUsers: string[]
  isConnected: boolean
  startChatWithUser: (userId: string) => Promise<boolean>
  stopChatWithUser: (userId: string) => Promise<void>
  sendMessageToUser: (userId: string, content: string) => Promise<boolean>
  activeChats: string[]
  messageThreads: Record<string, SignalRMessageThread>
  latestMessages: Record<string, SignalRMessage>
}

const SignalRContext = createContext<SignalRContextType | undefined>(undefined)

export function useSignalR() {
  const context = useContext(SignalRContext)
  if (context === undefined) {
    throw new Error("useSignalR must be used within a SignalRProvider")
  }
  return context
}

interface SignalRProviderProps {
  children: ReactNode
}

export function SignalRProvider({ children }: SignalRProviderProps) {
  const { data: session, status } = useSession()
  const [onlineUsers, setOnlineUsers] = useState<string[]>([])
  const [isConnected, setIsConnected] = useState(false)
  const [activeChats, setActiveChats] = useState<string[]>([])
  const [messageThreads, setMessageThreads] = useState<Record<string, SignalRMessageThread>>({})
  const [latestMessages, setLatestMessages] = useState<Record<string, SignalRMessage>>({})

  // Connect to presence hub when session is available
  useEffect(() => {
    if (status !== "authenticated" || !session) return

    const connectToPresenceHub = async () => {
      try {
        await startPresenceConnection({
          onUserOnline: (userId) => {
            setOnlineUsers((prev) => [...prev.filter((id) => id !== userId), userId])
          },
          onUserOffline: (userId) => {
            setOnlineUsers((prev) => prev.filter((id) => id !== userId))
          },
          onOnlineUsers: (users) => {
            setOnlineUsers(users)
          },
        })
        setIsConnected(true)
      } catch (error) {
        console.error("Failed to connect to presence hub:", error)
        setIsConnected(false)
      }
    }

    connectToPresenceHub()

    // Cleanup on unmount
    return () => {
      stopAllConnections()
      setIsConnected(false)
    }
  }, [session, status])

  // Function to start a chat with a user
  const startChatWithUser = async (userId: string): Promise<boolean> => {
    if (!userId || !session) return false

    try {
      const connection = await startMessageConnection(userId, {
        onReceiveMessageThread: (thread: SignalRMessageThread) => {
          setMessageThreads((prev) => ({
            ...prev,
            [userId]: thread,
          }))
        },
        onNewMessage: (message: SignalRMessage) => {
          // Update latest message
          setLatestMessages((prev) => ({
            ...prev,
            [userId]: message,
          }))

          // Update message thread if it exists
          setMessageThreads((prev) => {
            const thread = prev[userId]
            if (!thread) return prev

            return {
              ...prev,
              [userId]: {
                ...thread,
                messages: [...thread.messages, message],
              },
            }
          })
        },
      })

      if (connection) {
        setActiveChats((prev) => [...prev.filter((id) => id !== userId), userId])
        return true
      }
      return false
    } catch (error) {
      console.error(`Failed to start chat with user ${userId}:`, error)
      return false
    }
  }

  // Function to stop a chat with a user
  const stopChatWithUser = async (userId: string): Promise<void> => {
    if (!userId) return

    try {
      await stopMessageConnection(userId)
      setActiveChats((prev) => prev.filter((id) => id !== userId))
    } catch (error) {
      console.error(`Failed to stop chat with user ${userId}:`, error)
    }
  }

  // Function to send a message to a user
  const sendMessageToUser = async (userId: string, content: string): Promise<boolean> => {
    if (!userId || !content || !session) return false

    try {
      return await sendMessage(userId, content)
    } catch (error) {
      console.error(`Failed to send message to user ${userId}:`, error)
      return false
    }
  }

  const value = {
    onlineUsers,
    isConnected,
    startChatWithUser,
    stopChatWithUser,
    sendMessageToUser,
    activeChats,
    messageThreads,
    latestMessages,
  }

  return <SignalRContext.Provider value={value}>{children}</SignalRContext.Provider>
}
