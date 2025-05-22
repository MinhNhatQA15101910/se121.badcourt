"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Clock } from "lucide-react"
import type { ConversationType } from "@/lib/types"

interface ConversationItemProps {
  conversation: ConversationType
  isActive: boolean
  onClick: () => void
}

export default function ConversationItem({ conversation, isActive, onClick }: ConversationItemProps) {
  return (
    <div
      className={`p-4 hover:bg-[#f8f9fd] cursor-pointer transition-colors duration-200 ${
        isActive ? "bg-[#f0fdf4] border-l-4 border-l-[#23c16b]" : "border-l-4 border-l-transparent"
      }`}
      onClick={onClick}
    >
      <div className="flex gap-3">
        <div className="relative">
          <Avatar className="w-12 h-12 border border-[#e2e8f0]">
            <AvatarImage src={conversation.avatar || "/placeholder.svg"} alt={conversation.name} />
            <AvatarFallback>{conversation.name.charAt(0)}</AvatarFallback>
          </Avatar>
          {conversation.online && (
            <span className="absolute bottom-0 right-0 w-3 h-3 bg-[#23c16b] border-2 border-white rounded-full"></span>
          )}
          {conversation.unread > 0 && (
            <span className="absolute -top-1 -right-1 bg-[#ff424f] text-white text-xs min-w-5 h-5 flex items-center justify-center rounded-full px-1.5">
              {conversation.unread}
            </span>
          )}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex justify-between items-center">
            <span className="font-medium text-[#1e293b] truncate">{conversation.name}</span>
            <span className="text-xs text-[#94a3b8] whitespace-nowrap ml-2 flex items-center">
              <Clock className="w-3 h-3 mr-1" />
              {conversation.time}
            </span>
          </div>
          <p
            className={`text-sm ${conversation.unread > 0 ? "font-medium text-[#1e293b]" : "text-[#64748b]"} truncate mt-1`}
          >
            {conversation.lastMessage}
          </p>
        </div>
      </div>
    </div>
  )
}
