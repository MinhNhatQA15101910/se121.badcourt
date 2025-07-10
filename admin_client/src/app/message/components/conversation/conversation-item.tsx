"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { useSession } from "next-auth/react"
import type { SignalRGroup } from "@/lib/types"

interface ConversationItemProps {
  group: SignalRGroup
  isActive: boolean
  onClick: (otherUserId: string | null) => void
  onlineUsers: string[]
  isUnread: boolean
}

export default function ConversationItem({ group, isActive, onClick, onlineUsers, isUnread }: ConversationItemProps) {
  const { data: session } = useSession()

  // Find the other user in the group (not the current user)
  const otherUser = group.users.find((user) => user.id !== session?.user?.id)
  const isOnline = otherUser ? onlineUsers.includes(otherUser.id) : false

  // Get the display name and avatar
  const displayName = otherUser?.username || "Unknown User"
  const displayAvatar = otherUser?.photoUrl || "/placeholder.svg?height=48&width=48"

  // Get last message info
  const lastMessage = group.lastMessage
  const lastMessageText = lastMessage?.content || "No messages yet"
  const lastMessageTime = lastMessage
    ? new Date(lastMessage.messageSent).toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
        hour12: false, // 24-hour format
      })
    : new Date(group.updatedAt).toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
        hour12: false, // 24-hour format
      })

  const handleClick = () => {
    onClick(otherUser?.id || null)
  }

  return (
    <div
      className={`flex items-center p-4 hover:bg-gray-50 cursor-pointer border-l-4 transition-colors ${
        isActive ? "bg-green-50 border-l-green-500" : "border-l-transparent"
      }`}
      onClick={handleClick}
    >
      <div className="relative">
        <Avatar className="h-12 w-12">
          <AvatarImage
            src={displayAvatar || "/placeholder.svg"}
            alt={displayName}
            onError={(e) => {
              console.log(`[ConversationItem] Avatar failed to load for ${displayName}:`, displayAvatar)
              // Fallback to placeholder if image fails to load
              e.currentTarget.src = "/placeholder.svg?height=48&width=48"
            }}
          />
          <AvatarFallback className="bg-gray-200 text-gray-600">{displayName.charAt(0).toUpperCase()}</AvatarFallback>
        </Avatar>
        {isOnline && (
          <div className="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></div>
        )}
      </div>

      <div className="ml-3 flex-1 min-w-0">
        <div className="flex items-center justify-between">
          <h3
            className={`text-sm truncate ${
              isUnread
                ? `font-bold ${isActive ? "text-green-700" : "text-gray-900"}`
                : `font-medium ${isActive ? "text-green-700" : "text-gray-900"}`
            }`}
          >
            {displayName}
          </h3>
          <div className="flex items-center ml-2 flex-shrink-0">
            <span className="text-xs text-gray-500">{lastMessageTime}</span>
            {isUnread && <div className="ml-2 w-2 h-2 bg-green-500 rounded-full"></div>}
          </div>
        </div>

        <div className="flex items-center justify-between mt-1">
          <p className={`text-sm truncate flex-1 ${isUnread ? "font-semibold text-gray-900" : "text-gray-600"}`}>
            {lastMessage?.senderId === session?.user?.id ? "You: " : ""}
            {lastMessageText}
          </p>
        </div>
      </div>
    </div>
  )
}
