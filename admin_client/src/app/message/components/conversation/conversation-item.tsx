"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Clock, Users, MessageCircle } from "lucide-react"
import type { SignalRGroup } from "@/lib/types"
import { useSession } from "next-auth/react"

interface ConversationItemProps {
  group: SignalRGroup
  isActive: boolean
  onClick: (otherUserId: string | null) => void
  onlineUsers?: string[]
  isUnread?: boolean // New prop to control unread state from parent
}

export default function ConversationItem({ group, isActive, onClick, isUnread = false }: ConversationItemProps) {
  const { data: session } = useSession()

  // Get the other user ID (not current user)
  const getOtherUserId = () => {
    if (!session?.user?.id) return null
    return group.users.find((user) => user.id !== session.user.id)?.id || null
  }

  const otherUserId = getOtherUserId()

  const lastMessage = group.lastMessage
  const lastMessageTime = lastMessage
    ? new Date(lastMessage.messageSent).toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      })
    : new Date(group.updatedAt).toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      })

  // Get group avatar (use first user's photo or placeholder)
  const groupAvatar = group.users[0]?.photoUrl || "/placeholder.svg?height=48&width=48"

  return (
    <div
      className={`relative p-4 hover:bg-[#f8f9fd] cursor-pointer transition-colors duration-200 border-b border-gray-100 ${
        isActive ? "bg-[#f0fdf4] border-l-4 border-l-[#23c16b]" : "border-l-4 border-l-transparent"
      }`}
      onClick={() => onClick(otherUserId)}
    >
      {/* Unread message indicator - Green dot */}
      {isUnread && (
        <span className="absolute bottom-5 right-4 w-3 h-3 bg-[#22c55e] border-2 border-white rounded-full animate-pulse"></span>
      )}

      <div className="flex gap-3">
        <div className="relative">
          <Avatar className="w-12 h-12 border border-[#e2e8f0]">
            <AvatarImage src={groupAvatar || "/placeholder.svg"} alt={group.name} />
            <AvatarFallback className="bg-[#3b82f6] text-white font-semibold">
              {group.name.charAt(0).toUpperCase()}
            </AvatarFallback>
          </Avatar>

          {/* Group indicator */}
          <span className="absolute bottom-0 right-0 w-4 h-4 bg-[#3b82f6] border-2 border-white rounded-full flex items-center justify-center">
            <Users className="w-2 h-2 text-white" />
          </span>
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex justify-between items-start">
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1">
                <span className={`font-semibold text-[#1e293b] truncate text-base ${isUnread ? "font-bold" : ""}`}>
                  {group.users.find((user) => user.id != session?.user?.id)?.username || "Error"}
                </span>
              </div>
            </div>

            <div className="flex flex-col items-end gap-1">
              <span className="text-xs text-[#94a3b8] whitespace-nowrap flex items-center">
                <Clock className="w-3 h-3 mr-1" />
                {lastMessageTime}
              </span>

              {/* Active connections indicator */}
              {group.connections.filter((conn) => conn.connected).length > 0 && (
                <div className="flex items-center gap-1">
                  <div className="w-1.5 h-1.5 bg-[#23c16b] rounded-full animate-pulse"></div>
                  <span className="text-xs text-[#23c16b]">Active</span>
                </div>
              )}
            </div>
          </div>

          {/* Last message */}
          <div className="flex items-start gap-2">
            <MessageCircle className="w-3 h-3 text-[#94a3b8] mt-0.5 flex-shrink-0" />
            <p className={`text-sm ${isUnread ? "font-semibold text-[#1e293b]" : "text-[#64748b]"} truncate`}>
              {lastMessage ? (
                <>
                  <span className="font-medium text-[#22c55e]">{lastMessage.senderUsername}:</span>{" "}
                  {lastMessage.content || "Sent an attachment"}
                </>
              ) : (
                <span className="italic">No messages yet</span>
              )}
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
