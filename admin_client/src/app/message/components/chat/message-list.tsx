"use client"

import type React from "react"
import { Button } from "@/components/ui/button"
import { Loader2, ChevronUp } from "lucide-react"
import type { MessageType, PaginationState } from "@/lib/types"
import Message from "./message"
import DateSeparator from "./date-separator"

interface MessageListProps {
  messages: MessageType[]
  conversationName: string
  conversationAvatar: string
  messagesEndRef: React.RefObject<HTMLDivElement | null>
  onMessageRead?: (messageId: string) => void
  pagination?: PaginationState
  onLoadMore?: () => void
  onLoadPrevious?: () => void
}

export default function MessageList({
  messages,
  conversationName,
  conversationAvatar,
  messagesEndRef,
  onMessageRead,
  pagination,
  onLoadMore,
  onLoadPrevious,
}: MessageListProps) {
  // Group messages by date
  const groupedMessages: { [key: string]: MessageType[] } = {}

  messages.forEach((message) => {
    // Extract date from time string or use current date logic
    let date = "Today"

    // If the time contains a date, extract it
    if (message.time.includes("/")) {
      const parts = message.time.split(" ")
      date = parts[0] // Assuming format like "12/25/2023 10:30 AM"
    } else if (message.time.includes("Yesterday")) {
      date = "Yesterday"
    }

    if (!groupedMessages[date]) {
      groupedMessages[date] = []
    }

    groupedMessages[date].push(message)
  })

  return (
    <div className="flex-1 p-4 md:p-6 overflow-y-auto bg-slate-50 w-full h-full">
      <div className="flex flex-col gap-4 w-full max-w-4xl mx-auto min-h-full">
        {/* Load Previous Messages Button */}
        {pagination && pagination.hasPreviousPage && onLoadPrevious && (
          <div className="flex justify-center mb-4">
            <Button
              variant="outline"
              size="sm"
              onClick={onLoadPrevious}
              disabled={pagination.isLoading}
              className="flex items-center gap-2"
            >
              {pagination.isLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : <ChevronUp className="h-4 w-4" />}
              Load Previous Messages
            </Button>
          </div>
        )}

        {Object.entries(groupedMessages).map(([date, dateMessages]) => (
          <div key={date} className="space-y-4 w-full">
            <DateSeparator date={date} />

            {dateMessages.map((message) => (
              <Message
                key={message.id}
                message={message}
                conversationName={conversationName}
                conversationAvatar={conversationAvatar}
                onMessageRead={onMessageRead}
              />
            ))}
          </div>
        ))}

        {/* Load More Messages Button */}
        {pagination && pagination.hasNextPage && onLoadMore && (
          <div className="flex justify-center mt-4">
            <Button
              variant="outline"
              size="sm"
              onClick={onLoadMore}
              disabled={pagination.isLoading}
              className="flex items-center gap-2"
            >
              {pagination.isLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
              Load More Messages
            </Button>
          </div>
        )}

        {/* Pagination Info */}
        {pagination && (
          <div className="text-center text-xs text-gray-500 mt-2">
            Page {pagination.currentPage} of {pagination.totalPages} ({pagination.totalCount} total messages)
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>
    </div>
  )
}
