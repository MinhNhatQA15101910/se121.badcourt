"use client"

import type React from "react"
import { useEffect, useRef, useState, useCallback } from "react"
import { format, isToday, isYesterday } from "date-fns"
import { vi } from "date-fns/locale"
import { RefreshCw } from "lucide-react"

import type { MessageType, PaginationState } from "@/lib/types"
import Message from "./message"
import DateSeparator from "./date-separator"

interface MessageListProps {
  messages: MessageType[]
  conversationName: string
  conversationAvatar: string
  messagesEndRef: React.RefObject<HTMLDivElement>
  scrollContainerRef?: React.RefObject<HTMLDivElement>
  onMessageRead?: (messageId: string) => void
  pagination?: PaginationState
  onLoadMore?: () => Promise<boolean>
  onLoadPrevious?: () => Promise<boolean>
  onScroll?: () => void
}

export default function MessageList({
  messages,
  conversationName,
  conversationAvatar,
  messagesEndRef,
  scrollContainerRef,
  onMessageRead,
  pagination,
  onLoadMore,
  onLoadPrevious,
  onScroll,
}: MessageListProps) {
  const [isLoadingMore, setIsLoadingMore] = useState(false)
  const internalScrollRef = useRef<HTMLDivElement>(null)
  const [shouldMaintainScrollPosition, setShouldMaintainScrollPosition] = useState(false)
  const [previousScrollHeight, setPreviousScrollHeight] = useState(0)

  // Use external ref if provided, otherwise use internal ref
  const activeScrollRef = scrollContainerRef || internalScrollRef

  // Debounced scroll handler for better performance
  const handleScroll = useCallback(
    async (event: React.UIEvent<HTMLDivElement>) => {
      const container = event.currentTarget
      if (!container || !onLoadMore || !pagination) return

      // Call parent onScroll if provided
      onScroll?.()

      // Check if scrolled to top (with small threshold)
      const isAtTop = container.scrollTop <= 100

      if (isAtTop && pagination.hasNextPage && !pagination.isLoading && !isLoadingMore) {
        console.log("[MessageList] Auto-loading more messages...")
        setIsLoadingMore(true)
        setShouldMaintainScrollPosition(true)
        setPreviousScrollHeight(container.scrollHeight)

        try {
          await onLoadMore()
        } catch (error) {
          console.error("Error loading more messages:", error)
        } finally {
          setIsLoadingMore(false)
        }
      }
    },
    [onLoadMore, pagination, isLoadingMore, onScroll],
  )

  // Maintain scroll position after loading older messages
  useEffect(() => {
    if (shouldMaintainScrollPosition && activeScrollRef.current) {
      const container = activeScrollRef.current
      const newScrollHeight = container.scrollHeight
      const scrollDifference = newScrollHeight - previousScrollHeight

      // Maintain scroll position by adjusting scrollTop
      container.scrollTop = scrollDifference

      setShouldMaintainScrollPosition(false)
      setPreviousScrollHeight(0)
    }
  }, [messages.length, shouldMaintainScrollPosition, previousScrollHeight, activeScrollRef])

  // Group messages by date
  const groupedMessages = messages.reduce(
    (groups, message) => {
      // Parse message time - assuming it's in format "HH:mm" and we need to create a full date
      // For now, we'll use the current date. In a real app, you'd have a full timestamp
      const messageDate = new Date() // This should be the actual message date
      const dateKey = format(messageDate, "yyyy-MM-dd")

      if (!groups[dateKey]) {
        groups[dateKey] = []
      }
      groups[dateKey].push(message)
      return groups
    },
    {} as Record<string, MessageType[]>,
  )

  // Format date for display
  const formatDateForDisplay = (dateString: string) => {
    const date = new Date(dateString)
    if (isToday(date)) {
      return "Today"
    } else if (isYesterday(date)) {
      return "Yesterday"
    } else {
      return format(date, "EEEE, MMMM d, yyyy", { locale: vi })
    }
  }

  return (
    <div
      ref={activeScrollRef}
      className="flex-1 overflow-y-auto p-4 space-y-4"
      onScroll={handleScroll}
      style={{
        scrollBehavior: shouldMaintainScrollPosition ? "auto" : "smooth",
        // Ensure the container has proper height calculation
        minHeight: 0,
        height: "100%",
      }}
    >
      {/* Loading indicator for older messages */}
      {(isLoadingMore || pagination?.isLoading) && (
        <div className="flex items-center justify-center py-4">
          <RefreshCw className="w-5 h-5 animate-spin text-gray-400 mr-2" />
          <span className="text-sm text-gray-500">Loading older messages...</span>
        </div>
      )}

      {/* Pagination info */}
      {pagination && pagination.totalCount > 0 && (
        <div className="text-center py-2">
          <div className="text-xs text-gray-400">
            Showing {messages.length} of {pagination.totalCount} messages
            {pagination.totalPages > 1 && (
              <span>
                {" "}
                • Page {pagination.currentPage} of {pagination.totalPages}
              </span>
            )}
            {pagination.hasNextPage && (
              <span className="block mt-1 text-blue-500">Scroll to top to load more messages</span>
            )}
          </div>
        </div>
      )}

      {/* Messages grouped by date */}
      {Object.entries(groupedMessages).map(([dateKey, dayMessages]) => (
        <div key={dateKey}>
          <DateSeparator date={formatDateForDisplay(dateKey)} />
          <div className="space-y-4">
            {dayMessages.map((message) => (
              <Message
                key={message.id}
                message={message}
                conversationName={conversationName}
                conversationAvatar={conversationAvatar}
                onMessageRead={onMessageRead}
              />
            ))}
          </div>
        </div>
      ))}

      {/* Empty state */}
      {messages.length === 0 && (
        <div className="flex items-center justify-center h-full">
          <div className="text-center text-gray-500">
            <p className="text-lg font-medium">No messages yet</p>
            <p className="text-sm">Start the conversation by sending a message</p>
          </div>
        </div>
      )}

      {/* Scroll anchor - Make it more visible for debugging */}
      <div
        ref={messagesEndRef}
        style={{
          height: "1px",
          width: "100%",
          // Add some margin to ensure it's at the very bottom
          marginBottom: "10px",
        }}
      />
    </div>
  )
}
