"use client"

import type React from "react"
import { useEffect, useState } from "react"
import { useSession } from "next-auth/react"
import {
  startPresenceConnection,
  startGroupConnection,
  stopPresenceConnection,
  stopGroupConnection,
  getConnectionStates,
} from "@/services/signalr-service"
import type { SignalRGroup, SignalRGroupList, UserDto } from "@/lib/types"

interface ConnectionStates {
  presence: boolean
  message: boolean
  group: boolean
}

interface SignalRManagerProps {
  children: React.ReactNode
  onConnectionStateChange?: (states: ConnectionStates) => void
}

interface PresenceHandlers {
  onUserOnline: (userId: string) => void
  onUserOffline: (userId: string) => void
  onOnlineUsers: (users: string[]) => void
}

interface GroupHandlers {
  onReceiveGroups?: (groupList: SignalRGroupList) => void
  onJoinedGroup?: (group: SignalRGroup) => void
  onLeftGroup?: (groupId: string) => void
  onGroupUpdated?: (group: SignalRGroup) => void
  onUserJoinedGroup?: (groupId: string, user: UserDto) => void
  onUserLeftGroup?: (groupId: string, userId: string) => void
}

export default function SignalRManager({ children, onConnectionStateChange }: SignalRManagerProps) {
  const { data: session, status } = useSession()
  const [connectionInitialized, setConnectionInitialized] = useState(false)

  useEffect(() => {
    if (status !== "authenticated" || !session?.token || connectionInitialized) {
      return
    }

    let isMounted = true

    const initializeConnections = async () => {
      try {
        console.log("[SignalR Manager] Initializing connections...")

        // Define handlers with proper types
        const presenceHandlers: PresenceHandlers = {
          onUserOnline: (userId: string) => {
            console.log(`User ${userId} came online`)
          },
          onUserOffline: (userId: string) => {
            console.log(`User ${userId} went offline`)
          },
          onOnlineUsers: (users: string[]) => {
            console.log("Online users:", users)
          },
        }

        const groupHandlers: GroupHandlers = {
          onReceiveGroups: (groupList: SignalRGroupList) => {
            console.log("Received groups:", groupList)
          },
          onJoinedGroup: (group: SignalRGroup) => {
            console.log("Joined group:", group)
          },
          onLeftGroup: (groupId: string) => {
            console.log("Left group:", groupId)
          },
          onGroupUpdated: (group: SignalRGroup) => {
            console.log("Group updated:", group)
          },
          onUserJoinedGroup: (groupId: string, user: UserDto) => {
            console.log(`User ${user.username} joined group ${groupId}`)
          },
          onUserLeftGroup: (groupId: string, userId: string) => {
            console.log(`User ${userId} left group ${groupId}`)
          },
        }

        // Start connections
        await Promise.all([
          startPresenceConnection(session.token, presenceHandlers),
          startGroupConnection(session.token, groupHandlers),
        ])

        if (isMounted) {
          console.log("[SignalR Manager] Connections initialized successfully")
          setConnectionInitialized(true)

          // Notify parent component about connection states
          const states = getConnectionStates()
          onConnectionStateChange?.(states)
        }
      } catch (error) {
        console.error("[SignalR Manager] Failed to initialize connections:", error)
        if (isMounted) {
          setConnectionInitialized(false)
        }
      }
    }

    initializeConnections()

    // Cleanup function
    return () => {
      isMounted = false
      console.log("[SignalR Manager] Cleaning up connections...")

      // Stop connections
      Promise.all([stopPresenceConnection(), stopGroupConnection()])
        .then(() => {
          console.log("[SignalR Manager] Connections stopped successfully")
          setConnectionInitialized(false)
        })
        .catch((error) => {
          console.error("[SignalR Manager] Error stopping connections:", error)
        })
    }
  }, [session?.token, status, connectionInitialized, onConnectionStateChange])

  // Monitor connection states periodically
  useEffect(() => {
    if (status !== "authenticated" || !onConnectionStateChange || !connectionInitialized) {
      return
    }

    const interval = setInterval(() => {
      const states = getConnectionStates()
      onConnectionStateChange(states)
    }, 5000) // Check every 5 seconds

    return () => clearInterval(interval)
  }, [status, onConnectionStateChange, connectionInitialized])

  return <>{children}</>
}
