"use client"

import type React from "react"

import type { MessageType } from "@/lib/types"
import Message from "./message"
import DateSeparator from "./date-separator"

interface MessageListProps {
  messages: MessageType[]
  conversationName: string
  conversationAvatar: string
  messagesEndRef: React.RefObject<HTMLDivElement | null>
}

export default function MessageList({
  messages,
  conversationName,
  conversationAvatar,
  messagesEndRef,
}: MessageListProps) {
  // Group messages by date
  const groupedMessages: { [key: string]: MessageType[] } = {}

  messages.forEach((message) => {
    const date = message.time.includes("Today")
      ? "Today"
      : message.time.includes("Yesterday")
        ? "Yesterday"
        : message.time

    if (!groupedMessages[date]) {
      groupedMessages[date] = []
    }

    groupedMessages[date].push(message)
  })

  return (
    <div className="flex-1 p-4 md:p-6 overflow-y-auto bg-[#f8fafc] w-full h-full scrollbar-hide">
      <div className="flex flex-col gap-4 w-full max-w-4xl mx-auto min-h-full">
        {Object.entries(groupedMessages).map(([date, dateMessages]) => (
          <div key={date} className="space-y-4 w-full">
            <DateSeparator date={date} />

            {dateMessages.map((message) => (
              <Message
                key={message.id}
                message={message}
                conversationName={conversationName}
                conversationAvatar={conversationAvatar}
              />
            ))}
          </div>
        ))}

        <div ref={messagesEndRef} />
      </div>
    </div>
  )
}
