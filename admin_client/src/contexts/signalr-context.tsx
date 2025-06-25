"use client"

import { createContext, useContext, useEffect, useState, type ReactNode } from "react"
import { useSession } from "next-auth/react"
import {
  startPresenceConnection,
  startMessageConnection,
  startGroupConnection,
  joinGroup,
  leaveGroup,
  sendMessageToGroup,
  sendDirectMessage,
  markMessageAsRead,
  getMessageThread,
  getGroups,
  loadMoreMessages,
  loadPreviousMessages,
  stopAllConnections,
  getConnectionStates,
} from "@/services/signalr-service"
import type {
  SignalRMessage,
  SignalRMessageThread,
  SignalRGroup,
  SignalRGroupList,
  UserDto,
  PaginationState,
} from "@/lib/types"

interface SignalRContextType {
  // Connection states
  onlineUsers: string[]
  connectionStates: {
    presence: boolean
    message: boolean
    group: boolean
  }

  // Groups management with pagination
  joinedGroups: SignalRGroup[]
  groupsPagination: PaginationState
  activeGroupId: string | null

  // Messages with pagination
  messageThreads: Record<string, SignalRMessageThread>
  messagePagination: Record<string, PaginationState>
  latestMessages: Record<string, SignalRMessage>

  // Actions
  loadGroups: (page?: number, pageSize?: number) => Promise<boolean>
  joinGroupChat: (groupId: string) => Promise<boolean>
  leaveGroupChat: (groupId: string) => Promise<boolean>
  sendGroupMessage: (groupId: string, content: string, resources?: File[]) => Promise<boolean>
  sendUserMessage: (userId: string, content: string, resources?: File[]) => Promise<boolean>
  markAsRead: (messageId: string) => Promise<boolean>
  loadMessageThread: (groupId: string, page?: number, pageSize?: number) => Promise<boolean>
  loadMoreMessagesForGroup: (groupId: string) => Promise<boolean>
  loadPreviousMessagesForGroup: (groupId: string) => Promise<boolean>
  setActiveGroup: (groupId: string | null) => void
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

  // State management
  const [onlineUsers, setOnlineUsers] = useState<string[]>([])
  const [connectionStates, setConnectionStates] = useState({
    presence: false,
    message: false,
    group: false,
  })
  const [joinedGroups, setJoinedGroups] = useState<SignalRGroup[]>([])
  const [groupsPagination, setGroupsPagination] = useState<PaginationState>({
    currentPage: 1,
    totalPages: 1,
    pageSize: 20,
    totalCount: 0,
    hasNextPage: false,
    hasPreviousPage: false,
    isLoading: false,
  })
  const [activeGroupId, setActiveGroupId] = useState<string | null>(null)
  const [messageThreads, setMessageThreads] = useState<Record<string, SignalRMessageThread>>({})
  const [messagePagination, setMessagePagination] = useState<Record<string, PaginationState>>({})
  const [latestMessages, setLatestMessages] = useState<Record<string, SignalRMessage>>({})

  // Helper function to create pagination state
  const createPaginationState = (
    currentPage: number,
    totalPages: number,
    pageSize: number,
    totalCount: number,
    isLoading = false,
  ): PaginationState => ({
    currentPage,
    totalPages,
    pageSize,
    totalCount,
    hasNextPage: currentPage < totalPages,
    hasPreviousPage: currentPage > 1,
    isLoading,
  })

  // Initialize connections when session is available
  useEffect(() => {
    if (status !== "authenticated" || !session?.token) return

    const initializeConnections = async () => {
      try {
        // Start presence connection
        await startPresenceConnection(session.token, {
          onUserOnline: (userId) => {
            console.log(`User ${userId} came online`)
            setOnlineUsers((prev) => [...prev.filter((id) => id !== userId), userId])
          },
          onUserOffline: (userId) => {
            console.log(`User ${userId} went offline`)
            setOnlineUsers((prev) => prev.filter((id) => id !== userId))
          },
          onOnlineUsers: (users) => {
            console.log("Online users:", users)
            setOnlineUsers(users)
          },
        })

        // Start message connection
        await startMessageConnection(session.token, {
          onReceiveMessageThread: (messageThread: SignalRMessageThread) => {
            console.log("Received message thread with pagination:", messageThread)

            if (messageThread.items.length > 0) {
              const groupId = messageThread.items[0].groupId

              // Update message thread
              setMessageThreads((prev) => ({
                ...prev,
                [groupId]: messageThread,
              }))

              // Update pagination state for this group
              setMessagePagination((prev) => ({
                ...prev,
                [groupId]: createPaginationState(
                  messageThread.currentPage,
                  messageThread.totalPages,
                  messageThread.pageSize,
                  messageThread.totalCount,
                ),
              }))
            }
          },
          onNewMessage: (message: SignalRMessage) => {
            console.log("New direct message received:", message)

            // Update latest messages
            const key = message.groupId || message.senderId
            setLatestMessages((prev) => ({
              ...prev,
              [key]: message,
            }))

            // Update message thread if it exists
            if (message.groupId) {
              setMessageThreads((prev) => {
                const thread = prev[message.groupId!]
                if (!thread) return prev

                return {
                  ...prev,
                  [message.groupId!]: {
                    ...thread,
                    items: [...thread.items, message],
                    totalCount: thread.totalCount + 1,
                  },
                }
              })
            }
          },
          onMessageRead: (messageId, userId) => {
            console.log(`Message ${messageId} read by user ${userId}`)
            // Update message read status in threads
            setMessageThreads((prev) => {
              const updatedThreads = { ...prev }
              Object.keys(updatedThreads).forEach((groupId) => {
                const thread = updatedThreads[groupId]
                const updatedMessages = thread.items.map((msg) =>
                  msg.id === messageId ? { ...msg, dateRead: new Date().toISOString() } : msg,
                )
                updatedThreads[groupId] = { ...thread, items: updatedMessages }
              })
              return updatedThreads
            })
          },
        })

        // Start group connection
        await startGroupConnection(session.token, {
          onReceiveGroups: (groupList: SignalRGroupList) => {
            console.log("Received groups with pagination:", groupList)

            // Update groups
            setJoinedGroups(groupList.items)

            // Update groups pagination
            setGroupsPagination(
              createPaginationState(
                groupList.currentPage,
                groupList.totalPages,
                groupList.pageSize,
                groupList.totalCount,
              ),
            )
          },
          onJoinedGroup: (group: SignalRGroup) => {
            console.log("Joined group:", group)
            setJoinedGroups((prev) => {
              const filtered = prev.filter((g) => g.id !== group.id)
              return [...filtered, group]
            })
          },
          onLeftGroup: (groupId: string) => {
            console.log("Left group:", groupId)
            setJoinedGroups((prev) => prev.filter((g) => g.id !== groupId))

            // Clear message thread for left group
            setMessageThreads((prev) => {
              const updated = { ...prev }
              delete updated[groupId]
              return updated
            })

            // Clear pagination for left group
            setMessagePagination((prev) => {
              const updated = { ...prev }
              delete updated[groupId]
              return updated
            })
          },
          onGroupUpdated: (group: SignalRGroup) => {
            console.log("Group updated:", group)
            setJoinedGroups((prev) => prev.map((g) => (g.id === group.id ? group : g)))
          },
          onUserJoinedGroup: (groupId: string, user: UserDto) => {
            console.log(`User ${user.username} joined group ${groupId}`)
            setJoinedGroups((prev) =>
              prev.map((group) =>
                group.id === groupId
                  ? { ...group, users: [...group.users.filter((u) => u.id !== user.id), user] }
                  : group,
              ),
            )
          },
          onUserLeftGroup: (groupId: string, userId: string) => {
            console.log(`User ${userId} left group ${groupId}`)
            setJoinedGroups((prev) =>
              prev.map((group) =>
                group.id === groupId ? { ...group, users: group.users.filter((u) => u.id !== userId) } : group,
              ),
            )
          },
        })

        // Update connection states
        setConnectionStates(getConnectionStates())

        // Load initial groups
        await loadGroups(1, 20)
      } catch (error) {
        console.error("Failed to initialize SignalR connections:", error)
      }
    }

    initializeConnections()

    // Update connection states periodically
    const interval = setInterval(() => {
      setConnectionStates(getConnectionStates())
    }, 5000)

    // Cleanup on unmount
    return () => {
      clearInterval(interval)
      stopAllConnections()
      setConnectionStates({ presence: false, message: false, group: false })
    }
  }, [session?.token, status])

  // Action functions
  const loadGroups = async (page = 1, pageSize = 20): Promise<boolean> => {
    try {
      setGroupsPagination((prev) => ({ ...prev, isLoading: true }))
      const success = await getGroups(page, pageSize)
      if (!success) {
        setGroupsPagination((prev) => ({ ...prev, isLoading: false }))
      }
      return success
    } catch (error) {
      console.error("Failed to load groups:", error)
      setGroupsPagination((prev) => ({ ...prev, isLoading: false }))
      return false
    }
  }

  const joinGroupChat = async (groupId: string): Promise<boolean> => {
    try {
      const success = await joinGroup(groupId)
      if (success) {
        setActiveGroupId(groupId)
        // Load message thread for the group
        await loadMessageThread(groupId)
      }
      return success
    } catch (error) {
      console.error(`Failed to join group ${groupId}:`, error)
      return false
    }
  }

  const leaveGroupChat = async (groupId: string): Promise<boolean> => {
    try {
      const success = await leaveGroup(groupId)
      if (success && activeGroupId === groupId) {
        setActiveGroupId(null)
      }
      return success
    } catch (error) {
      console.error(`Failed to leave group ${groupId}:`, error)
      return false
    }
  }

  const sendGroupMessage = async (groupId: string, content: string, resources?: File[]): Promise<boolean> => {
    try {
      return await sendMessageToGroup(groupId, content, resources)
    } catch (error) {
      console.error(`Failed to send message to group ${groupId}:`, error)
      return false
    }
  }

  const sendUserMessage = async (userId: string, content: string, resources?: File[]): Promise<boolean> => {
    try {
      return await sendDirectMessage(userId, content, resources)
    } catch (error) {
      console.error(`Failed to send message to user ${userId}:`, error)
      return false
    }
  }

  const markAsRead = async (messageId: string): Promise<boolean> => {
    try {
      return await markMessageAsRead(messageId)
    } catch (error) {
      console.error(`Failed to mark message ${messageId} as read:`, error)
      return false
    }
  }

  const loadMessageThread = async (groupId: string, page = 1, pageSize = 50): Promise<boolean> => {
    try {
      // Set loading state
      setMessagePagination((prev) => ({
        ...prev,
        [groupId]: {
          ...prev[groupId],
          isLoading: true,
        },
      }))

      const success = await getMessageThread(groupId, page, pageSize)
      if (!success) {
        setMessagePagination((prev) => ({
          ...prev,
          [groupId]: {
            ...prev[groupId],
            isLoading: false,
          },
        }))
      }
      return success
    } catch (error) {
      console.error(`Failed to load message thread for group ${groupId}:`, error)
      setMessagePagination((prev) => ({
        ...prev,
        [groupId]: {
          ...prev[groupId],
          isLoading: false,
        },
      }))
      return false
    }
  }

  const loadMoreMessagesForGroup = async (groupId: string): Promise<boolean> => {
    try {
      const currentPagination = messagePagination[groupId]
      if (!currentPagination || !currentPagination.hasNextPage || currentPagination.isLoading) {
        return false
      }

      return await loadMoreMessages(groupId, currentPagination.currentPage, currentPagination.pageSize)
    } catch (error) {
      console.error(`Failed to load more messages for group ${groupId}:`, error)
      return false
    }
  }

  const loadPreviousMessagesForGroup = async (groupId: string): Promise<boolean> => {
    try {
      const currentPagination = messagePagination[groupId]
      if (!currentPagination || !currentPagination.hasPreviousPage || currentPagination.isLoading) {
        return false
      }

      return await loadPreviousMessages(groupId, currentPagination.currentPage, currentPagination.pageSize)
    } catch (error) {
      console.error(`Failed to load previous messages for group ${groupId}:`, error)
      return false
    }
  }

  const setActiveGroup = (groupId: string | null) => {
    setActiveGroupId(groupId)
  }

  const value: SignalRContextType = {
    onlineUsers,
    connectionStates,
    joinedGroups,
    groupsPagination,
    activeGroupId,
    messageThreads,
    messagePagination,
    latestMessages,
    loadGroups,
    joinGroupChat,
    leaveGroupChat,
    sendGroupMessage,
    sendUserMessage,
    markAsRead,
    loadMessageThread,
    loadMoreMessagesForGroup,
    loadPreviousMessagesForGroup,
    setActiveGroup,
  }

  return <SignalRContext.Provider value={value}>{children}</SignalRContext.Provider>
}
