"use client"

import { ArrowLeft} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import type { ConversationType } from "@/lib/types"

interface ChatHeaderProps {
  conversation: ConversationType
  onBackClick: () => void
}

export default function ChatHeader({ conversation, onBackClick }: ChatHeaderProps) {
  return (
    <div className="pl-4 pr-4 h-16 border-b border-[#e2e8f0] flex items-center justify-between bg-white">
      <div className="flex items-center gap-3">
        <Button variant="ghost" size="icon" className="md:hidden rounded-full hover:bg-[#f1f5f9]" onClick={onBackClick}>
          <ArrowLeft className="w-5 h-5 text-[#64748b]" />
        </Button>
        <Avatar className="w-10 h-10 border border-[#e2e8f0]">
          <AvatarImage src={conversation.avatar || "/placeholder.svg"} alt={conversation.name} />
          <AvatarFallback>{conversation.name.charAt(0)}</AvatarFallback>
        </Avatar>
        <div className="flex flex-col">
          <span className="font-medium text-[#1e293b]">{conversation.name}</span>
          <span className="text-xs text-[#23c16b] flex items-center">
            <span
              className={`w-2 h-2 rounded-full ${conversation.online ? "bg-[#23c16b]" : "bg-[#94a3b8]"} mr-1`}
            ></span>
            {conversation.online ? "Active now" : "Offline"}
          </span>
        </div>
      </div>
      
    </div>
  )
}
