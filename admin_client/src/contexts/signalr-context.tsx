"use client"

import { createContext, useContext, useEffect, useState, useCallback, type ReactNode } from "react"
import { useSession } from "next-auth/react"
import {
  startPresenceConnection,
  startGroupConnection,
  connectToUser,
  refreshGroups,
  stopMessageConnection,
  getConnectionStates,
} from "@/services/signalr-service"
import { messageService } from "@/services/messageService"
import { groupService } from "@/services/groupService"
import type { SignalRMessage, SignalRMessageThread, SignalRGroup, SignalRGroupList, PaginationState } from "@/lib/types"

interface SignalRContextType {
  // Connection states
  onlineUsers: string[]
  connectionStates: {
    presence: boolean
    message: boolean
    group: boolean
  }
  // Groups (global)
  joinedGroups: SignalRGroup[]
  groupsPagination: PaginationState
  unreadMessagesCount: number
  // Messages (local to message page)
  messageThreads: Record<string, SignalRMessageThread>
  latestMessages: Record<string, SignalRMessage>
  messagePagination: Record<string, PaginationState>
  // Actions
  refreshGroupsList: () => Promise<boolean>
  loadMoreGroups: () => Promise<boolean>
  connectToUserForChat: (otherUserId: string) => Promise<boolean>
  disconnectFromUser: () => Promise<void>
  loadMoreMessages: (otherUserId: string) => Promise<boolean>
  // Compatibility methods for existing components
  loadGroups: (page?: number, pageSize?: number) => Promise<boolean>
  joinGroupChat: (groupId: string) => Promise<boolean>
  loadMessageThread: (groupId: string, page?: number, pageSize?: number) => Promise<boolean>
  // Debug methods
  forceRefreshGroups: () => Promise<void>
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

  const [unreadMessagesCount] = useState(0)
  const [messageThreads, setMessageThreads] = useState<Record<string, SignalRMessageThread>>({})
  const [latestMessages, setLatestMessages] = useState<Record<string, SignalRMessage>>({})
  const [messagePagination, setMessagePagination] = useState<Record<string, PaginationState>>({})

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

  // Helper function to sort messages by date (oldest first)
  const sortMessagesByDate = (messages: SignalRMessage[]): SignalRMessage[] => {
    return [...messages].sort((a, b) => new Date(a.messageSent).getTime() - new Date(b.messageSent).getTime())
  }

  // Helper function to update or add group to the top of the list
  const updateOrAddGroupToTop = useCallback((newGroup: SignalRGroup) => {
    setJoinedGroups((prevGroups) => {
      // Check if group already exists
      const existingGroupIndex = prevGroups.findIndex((group) => group.id === newGroup.id)

      if (existingGroupIndex !== -1) {
        // Group exists - replace it and move to top
        const updatedGroups = [...prevGroups]
        updatedGroups.splice(existingGroupIndex, 1) // Remove from current position
        return [newGroup, ...updatedGroups] // Add to top
      } else {
        // Group doesn't exist - add to top
        const result = [newGroup, ...prevGroups]

        // Update total count for new group
        setGroupsPagination((prev) => ({
          ...prev,
          totalCount: prev.totalCount + 1,
        }))

        return result
      }
    })
  }, [])

  // Force refresh groups from API
  const forceRefreshGroups = useCallback(async () => {
    try {
      const response = await groupService.getGroups({
        pageNumber: 1,
        pageSize: 20,
      })

      setJoinedGroups(response.items)
      setGroupsPagination(
        createPaginationState(response.currentPage, response.totalPages, response.pageSize, response.totalCount),
      )
    } catch (error) {
      console.error("[SignalR Context] Force refresh failed:", error)
    }
  }, [])

  // GLOBAL: Initialize Presence and Group connections once
  useEffect(() => {
    if (status !== "authenticated" || !session?.token) return

    const initializeGlobalConnections = async () => {
      try {
        // Start presence connection (global)
        await startPresenceConnection(session.token, {
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

        // Start group connection (global)
        await startGroupConnection(session.token, {
          onReceiveGroups: (groupList: SignalRGroupList) => {
            setJoinedGroups(groupList.items)
            setGroupsPagination(
              createPaginationState(
                groupList.currentPage,
                groupList.totalPages,
                groupList.pageSize,
                groupList.totalCount,
              ),
            )
          },
          onNewMessageReceived: (groupDto: SignalRGroup) => {
            updateOrAddGroupToTop(groupDto)
          },
          onGroupCreated: (newGroup: SignalRGroup) => {
            updateOrAddGroupToTop(newGroup)
          },
        })
      } catch (error) {
        console.error("Failed to initialize GLOBAL SignalR connections:", error)
      }
    }

    initializeGlobalConnections()

    // Update connection states periodically
    const interval = setInterval(() => {
      setConnectionStates(getConnectionStates())
    }, 5000)

    return () => {
      clearInterval(interval)
      // Don't stop global connections on unmount
    }
  }, [session?.token, status, updateOrAddGroupToTop])

  // Action functions
  const refreshGroupsList = async (): Promise<boolean> => {
    try {
      if (!session?.token) return false
      setGroupsPagination((prev) => ({ ...prev, isLoading: true }))
      const success = await refreshGroups(session.token)
      if (!success) {
        setGroupsPagination((prev) => ({ ...prev, isLoading: false }))
      }
      return success
    } catch (error) {
      console.error("Failed to refresh groups:", error)
      setGroupsPagination((prev) => ({ ...prev, isLoading: false }))
      return false
    }
  }

  const loadMoreGroups = async (): Promise<boolean> => {
    try {
      if (!session?.token) return false
      const currentPagination = groupsPagination
      if (!currentPagination.hasNextPage || currentPagination.isLoading) {
        return false
      }

      // Set loading state
      setGroupsPagination((prev) => ({ ...prev, isLoading: true }))

      // Load next page via API
      const nextPage = currentPagination.currentPage + 1
      const response = await groupService.getGroups({
        pageNumber: nextPage,
        pageSize: currentPagination.pageSize,
      })

      // Append new groups to existing list
      setJoinedGroups((prev) => [...prev, ...response.items])

      // Update pagination state
      setGroupsPagination(
        createPaginationState(response.currentPage, response.totalPages, response.pageSize, response.totalCount, false),
      )

      return true
    } catch (error) {
      console.error("Failed to load more groups:", error)
      // Reset loading state on error
      setGroupsPagination((prev) => ({ ...prev, isLoading: false }))
      return false
    }
  }

  const connectToUserForChat = async (otherUserId: string): Promise<boolean> => {
    try {
      if (!session?.token) return false

      // Setup message callbacks before connecting
      const messageCallbacks = {
        onReceiveMessageThread: (messageThread: SignalRMessageThread) => {
          // Sort messages by date (oldest first) to ensure correct order
          const sortedMessages = sortMessagesByDate(messageThread.items)

          // Store message thread by the other user ID (SignalR loads page 1)
          setMessageThreads((prev) => ({
            ...prev,
            [otherUserId]: {
              ...messageThread,
              items: sortedMessages,
            },
          }))

          // Set pagination state for page 1
          setMessagePagination((prev) => ({
            ...prev,
            [otherUserId]: createPaginationState(
              messageThread.currentPage,
              messageThread.totalPages,
              messageThread.pageSize,
              messageThread.totalCount,
            ),
          }))

          // Update latest message if available
          if (sortedMessages.length > 0) {
            const latestMessage = sortedMessages[sortedMessages.length - 1]
            setLatestMessages((prev) => ({
              ...prev,
              [otherUserId]: latestMessage,
            }))
          }
        },
        onNewMessage: (message: SignalRMessage) => {
          // Add new message to existing thread (append to end since it's the newest)
          setMessageThreads((prev) => {
            const existingThread = prev[otherUserId]
            if (existingThread) {
              return {
                ...prev,
                [otherUserId]: {
                  ...existingThread,
                  items: [...existingThread.items, message], // Append to end
                  totalCount: existingThread.totalCount + 1,
                },
              }
            } else {
              // Create new thread if doesn't exist
              return {
                ...prev,
                [otherUserId]: {
                  currentPage: 1,
                  totalPages: 1,
                  pageSize: 20,
                  totalCount: 1,
                  items: [message],
                },
              }
            }
          })

          // Update latest message
          setLatestMessages((prev) => ({
            ...prev,
            [otherUserId]: message,
          }))
        },
      }

      const success = await connectToUser(session.token, otherUserId, messageCallbacks)
      if (success) {
        // Sau khi connect thành công, force refresh groups để đảm bảo có group mới
        setTimeout(async () => {
          await forceRefreshGroups()
        }, 2000) // Wait 2 seconds for backend to create group
      }
      return success
    } catch (error) {
      console.error(`Failed to connect to user ${otherUserId}:`, error)
      return false
    }
  }

  const loadMoreMessages = async (otherUserId: string): Promise<boolean> => {
    try {
      if (!session?.token) return false
      const currentPagination = messagePagination[otherUserId]
      if (!currentPagination || !currentPagination.hasNextPage || currentPagination.isLoading) {
        return false
      }

      // Set loading state
      setMessagePagination((prev) => ({
        ...prev,
        [otherUserId]: { ...currentPagination, isLoading: true },
      }))

      // Load next page via API
      const nextPage = currentPagination.currentPage + 1
      const response = await messageService.getMessages({
        otherUserId,
        pageNumber: nextPage,
        pageSize: currentPagination.pageSize,
      })

      // Sort the new messages and prepend to existing messages (older messages first)
      const sortedNewMessages = sortMessagesByDate(response.items)
      setMessageThreads((prev) => {
        const existingThread = prev[otherUserId]
        if (existingThread) {
          return {
            ...prev,
            [otherUserId]: {
              ...response,
              items: [...sortedNewMessages, ...existingThread.items], // Prepend older messages
            },
          }
        }
        return prev
      })

      // Update pagination state
      setMessagePagination((prev) => ({
        ...prev,
        [otherUserId]: createPaginationState(
          response.currentPage,
          response.totalPages,
          response.pageSize,
          response.totalCount,
          false,
        ),
      }))

      return true
    } catch (error) {
      console.error(`Failed to load more messages for user ${otherUserId}:`, error)
      // Reset loading state on error
      const currentPagination = messagePagination[otherUserId]
      if (currentPagination) {
        setMessagePagination((prev) => ({
          ...prev,
          [otherUserId]: { ...currentPagination, isLoading: false },
        }))
      }
      return false
    }
  }

  const disconnectFromUser = async (): Promise<void> => {
    try {
      await stopMessageConnection()
      setMessageThreads({})
      setLatestMessages({})
      setMessagePagination({})
    } catch (error) {
      console.error("Failed to disconnect from user:", error)
    }
  }

  const loadGroups = async (): Promise<boolean> => {
    return await refreshGroupsList()
  }

  const joinGroupChat = async (): Promise<boolean> => {
    return true
  }

  const loadMessageThread = async (): Promise<boolean> => {
    return true
  }

  const value: SignalRContextType = {
    onlineUsers,
    connectionStates,
    joinedGroups,
    groupsPagination,
    unreadMessagesCount,
    messageThreads,
    latestMessages,
    messagePagination,
    refreshGroupsList,
    loadMoreGroups,
    connectToUserForChat,
    disconnectFromUser,
    loadMoreMessages,
    loadGroups,
    joinGroupChat,
    loadMessageThread,
    forceRefreshGroups,
  }

  return <SignalRContext.Provider value={value}>{children}</SignalRContext.Provider>
}
