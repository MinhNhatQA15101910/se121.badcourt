"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { CheckCheck } from "lucide-react"
import Image from "next/image"
import type { MessageType } from "@/lib/types"
import { useState, useEffect } from "react"

interface MessageProps {
  message: MessageType
  conversationName: string
  conversationAvatar: string
  onMessageRead?: (messageId: string) => void
}

export default function Message({ message, conversationName, conversationAvatar, onMessageRead }: MessageProps) {
  const [imageError, setImageError] = useState(false)

  // Intersection Observer to detect when message is visible
  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !message.sent && onMessageRead) {
          onMessageRead(message.id.toString())
        }
      },
      { threshold: 0.5 },
    )

    const messageElement = document.getElementById(`message-${message.id}`)
    if (messageElement) {
      observer.observe(messageElement)
    }

    return () => {
      if (messageElement) {
        observer.unobserve(messageElement)
      }
    }
  }, [message.id, message.sent, onMessageRead])

  return (
    <div id={`message-${message.id}`} className={`flex ${message.sent ? "justify-end" : "justify-start"}`}>
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
                ? "bg-green-500 text-white rounded-2xl rounded-tr-sm shadow-sm"
                : "bg-white border border-gray-200 rounded-2xl rounded-tl-sm shadow-sm"
            } 
              p-3 px-4`}
          >
            {/* Show sender name for group messages */}
            {!message.sent && message.senderUsername && (
              <div className="text-xs font-medium text-gray-600 mb-1">{message.senderUsername}</div>
            )}

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

            {/* Display resources/files */}
            {message.resources && message.resources.length > 0 && (
              <div className={`${message.text && message.text.trim() !== "" ? "mt-2" : ""} space-y-1`}>
                {message.resources.map((resource) => (
                  <div key={resource.id} className="flex items-center gap-2 text-xs">
                    <span className="truncate">{resource.fileName}</span>
                    <span className="text-gray-500">({(resource.fileSize / 1024).toFixed(1)} KB)</span>
                  </div>
                ))}
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
            <span className="text-xs text-slate-400">{message.time}</span>
            {message.sent && <CheckCheck className="w-3 h-3 text-green-500" />}
          </div>
        </div>
      </div>
    </div>
  )
}
