"use client"

import type React from "react"

import { useEffect } from "react"
import { useSession } from "next-auth/react"
import {
  startPresenceConnection,
  startMessageConnection,
  startGroupConnection,
  stopPresenceConnection,
  stopMessageConnection,
  stopGroupConnection,
  getConnectionStates,
} from "@/services/signalr-service"

interface SignalRManagerProps {
  children: React.ReactNode
  onConnectionStateChange?: (states: { presence: boolean; message: boolean; group: boolean }) => void
}

export default function SignalRManager({ children, onConnectionStateChange }: SignalRManagerProps) {
  const { data: session, status } = useSession()

  useEffect(() => {
    if (status !== "authenticated" || !session?.token) {
      return
    }

    let mounted = true

    const initializeConnections = async () => {
      try {
        console.log("[SignalR Manager] Initializing connections...")

        // Start all connections
        await Promise.all([
          startPresenceConnection(session.token, {
            onUserOnline: (userId) => console.log(`User ${userId} came online`),
            onUserOffline: (userId) => console.log(`User ${userId} went offline`),
            onOnlineUsers: (users) => console.log("Online users:", users),
          }),
          startMessageConnection(session.token, {
            onNewMessage: (message) => console.log("New message:", message),
            onMessageRead: (messageId, userId) => console.log(`Message ${messageId} read by ${userId}`),
          }),
          startGroupConnection(session.token, {
            onJoinedGroup: (group) => console.log("Joined group:", group),
            onLeftGroup: (groupId) => console.log("Left group:", groupId),
            onGroupUpdated: (group) => console.log("Group updated:", group),
          }),
        ])

        if (mounted) {
          console.log("[SignalR Manager] All connections initialized")

          // Notify parent component about connection states
          const states = getConnectionStates()
          onConnectionStateChange?.(states)
        }
      } catch (error) {
        console.error("[SignalR Manager] Failed to initialize connections:", error)
      }
    }

    initializeConnections()

    // Cleanup function
    return () => {
      mounted = false
      console.log("[SignalR Manager] Cleaning up connections...")

      // Stop all connections when component unmounts
      Promise.all([stopPresenceConnection(), stopMessageConnection(), stopGroupConnection()])
        .then(() => {
          console.log("[SignalR Manager] All connections stopped")
        })
        .catch((error) => {
          console.error("[SignalR Manager] Error stopping connections:", error)
        })
    }
  }, [session?.token, status, onConnectionStateChange])

  // Monitor connection states periodically
  useEffect(() => {
    if (status !== "authenticated" || !onConnectionStateChange) {
      return
    }

    const interval = setInterval(() => {
      const states = getConnectionStates()
      onConnectionStateChange(states)
    }, 5000) // Check every 5 seconds

    return () => clearInterval(interval)
  }, [status, onConnectionStateChange])

  return <>{children}</>
}
