"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { CheckCheck } from "lucide-react"
import Image from "next/image"
import type { MessageType } from "@/lib/types"
import { useState } from "react"

interface MessageProps {
  message: MessageType
  conversationName: string
  conversationAvatar: string
}

export default function Message({ message, conversationName, conversationAvatar }: MessageProps) {
  const [imageError, setImageError] = useState(false)

  return (
    <div className={`flex ${message.sent ? "justify-end" : "justify-start"}`}>
      <div className={`flex gap-2 max-w-[80%] ${message.sent ? "flex-row-reverse" : ""}`}>
        {!message.sent && (
          <Avatar className="w-8 h-8 mt-1">
            <AvatarImage src={conversationAvatar || "/placeholder.svg"} alt={conversationName} />
            <AvatarFallback>{conversationName.charAt(0)}</AvatarFallback>
          </Avatar>
        )}
        <div className="flex flex-col gap-1">
          <div
            className={`${
              message.sent
                ? "bg-[#23c16b] text-white rounded-2xl rounded-tr-sm shadow-sm"
                : "bg-white border border-[#e5e7eb] rounded-2xl rounded-tl-sm shadow-sm"
            } 
              p-3 px-4`}
          >
            {message.text && message.text.trim() !== "" && <p className="text-sm">{message.text}</p>}

            {/* Display image if available */}
            {message.imageUrl && !imageError && (
              <div className={`${message.text && message.text.trim() !== "" ? "mt-2" : ""} rounded-lg overflow-hidden`}>
                <Image
                  src={message.imageUrl || "/placeholder.svg"}
                  alt="Shared image"
                  width={300}
                  height={200}
                  className="rounded-lg max-w-full object-contain"
                  onError={() => setImageError(true)}
                />
              </div>
            )}

            {/* Legacy support for hasImage property */}
            {(message.hasImage || imageError) && (
              <div className={`${message.text && message.text.trim() !== "" ? "mt-2" : ""} rounded-lg overflow-hidden`}>
                <Image
                  src="/placeholder.svg?height=200&width=300"
                  alt="Image placeholder"
                  width={300}
                  height={200}
                  className="rounded-lg"
                />
              </div>
            )}
          </div>
          <div className={`flex items-center gap-1 ${message.sent ? "justify-end" : ""}`}>
            <span className="text-xs text-[#9fa7be]">{message.time}</span>
            {message.sent && <CheckCheck className="w-3 h-3 text-[#23c16b]" />}
          </div>
        </div>
      </div>
    </div>
  )
}
