"use client"

import type React from "react"
import { useState, useRef, useEffect, useCallback } from "react"

import type { ConversationType } from "@/lib/types"
import { useSignalR } from "@/contexts/signalr-context"
import { messageService, type SendMessageParams } from "@/services/messageService"
import ChatHeader from "@/app/message/components/chat/chat-header"
import MessageList from "@/app/message/components/chat/message-list"
import MessageInput from "@/app/message/components/chat/message-input"
import { useSession } from "next-auth/react"

interface ChatAreaProps {
  conversation: ConversationType
  showConversationList: boolean
  onBackClick: () => void
  onSendMessage: (message: string, imageUrl?: string) => void
}

export default function ChatArea({ conversation, showConversationList, onBackClick }: ChatAreaProps) {
  const [message, setMessage] = useState("")
  const [isSending, setIsSending] = useState(false)
  const [isUserNearBottom, setIsUserNearBottom] = useState(true)
  const [isInitialLoad, setIsInitialLoad] = useState(true)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const scrollContainerRef = useRef<HTMLDivElement>(null)
  const previousMessagesLengthRef = useRef(0)
  const previousConversationIdRef = useRef<string | null>(null)

  const { messagePagination, loadMoreMessages } = useSignalR()
  useSession()

  // Get pagination info for current conversation
  const currentPagination = conversation.userId ? messagePagination[conversation.userId] : undefined

  // Improved scroll to bottom function
  const scrollToBottom = useCallback((behavior: ScrollBehavior = "smooth") => {
    if (!scrollContainerRef.current) return

    const container = scrollContainerRef.current
    
    // Method 1: Scroll to bottom using scrollTop
    const scrollToBottomDirect = () => {
      container.scrollTop = container.scrollHeight
    }

    // Method 2: Use scrollIntoView on the end element
    const scrollToBottomElement = () => {
      if (messagesEndRef.current) {
        messagesEndRef.current.scrollIntoView({ 
          behavior, 
          block: "end",
          inline: "nearest"
        })
      }
    }

    // Try both methods with a small delay to ensure DOM is updated
    if (behavior === "auto") {
      // For instant scroll, use direct method
      scrollToBottomDirect()
    } else {
      // For smooth scroll, try element method first, then fallback to direct
      scrollToBottomElement()
      
      // Fallback after a short delay
      setTimeout(() => {
        scrollToBottomDirect()
      }, 100)
    }

    console.log("[ChatArea] Scrolled to bottom, container height:", container.scrollHeight)
  }, [])

  // Check if user is near bottom of messages
  const checkIfUserNearBottom = useCallback(() => {
    if (!scrollContainerRef.current) return false

    const container = scrollContainerRef.current
    const threshold = 150 // Increased threshold
    const isNearBottom = container.scrollHeight - container.scrollTop - container.clientHeight <= threshold

    return isNearBottom
  }, [])

  // Handle scroll events to track user position
  const handleScroll = useCallback(() => {
    const nearBottom = checkIfUserNearBottom()
    setIsUserNearBottom(nearBottom)
  }, [checkIfUserNearBottom])

  // Reset states when conversation changes
  useEffect(() => {
    if (previousConversationIdRef.current !== conversation.id) {
      console.log("[ChatArea] Conversation changed, resetting scroll states")
      setIsInitialLoad(true)
      setIsUserNearBottom(true)
      previousMessagesLengthRef.current = 0
      previousConversationIdRef.current = conversation.id
    }
  }, [conversation.id])

  // Improved smart scroll logic
  useEffect(() => {
    const currentMessages = conversation.messages || []
    const currentLength = currentMessages.length
    const previousLength = previousMessagesLengthRef.current

    console.log("[ChatArea] Messages effect:", {
      currentLength,
      previousLength,
      isInitialLoad,
      isUserNearBottom,
      isLoading: currentPagination?.isLoading,
    })

    // Don't scroll if we're loading older messages (pagination)
    if (currentPagination?.isLoading) {
      console.log("[ChatArea] Skipping scroll - loading older messages")
      return
    }

    // Case 1: Initial load - always scroll to bottom instantly
    if (isInitialLoad && currentLength > 0) {
      console.log("[ChatArea] Initial load - scrolling to bottom")
      
      // Use multiple timeouts to ensure DOM is fully rendered
      setTimeout(() => {
        scrollToBottom("auto") // Instant scroll for initial load
      }, 50)
      
      setTimeout(() => {
        scrollToBottom("auto") // Double check after more time
        setIsInitialLoad(false)
        previousMessagesLengthRef.current = currentLength
      }, 200)
      
      return
    }

    // Case 2: New messages added (not initial load)
    if (currentLength > previousLength && !isInitialLoad) {
      // Only scroll if user is near bottom (not scrolled up to read old messages)
      if (isUserNearBottom) {
        console.log("[ChatArea] New message + user near bottom - scrolling to bottom")
        
        // Use multiple attempts to ensure scroll works
        setTimeout(() => {
          scrollToBottom("smooth")
        }, 50)
        
        setTimeout(() => {
          scrollToBottom("auto") // Force scroll if smooth didn't work
        }, 300)
      } else {
        console.log("[ChatArea] New message but user scrolled up - not scrolling")
      }
    }

    // Update previous length
    previousMessagesLengthRef.current = currentLength
  }, [conversation.messages, isInitialLoad, isUserNearBottom, currentPagination?.isLoading, scrollToBottom])

  // Handle sending a message via API
  const handleSendMessage = async (text: string, files?: File[]) => {
    if (text.trim() === "" && (!files || files.length === 0)) return

    if (!conversation.userId) {
      console.error("No recipient ID available")
      return
    }

    setIsSending(true)

    try {
      console.log("[ChatArea] Sending message via API:", { text, files, recipientId: conversation.userId })

      const messageData: SendMessageParams = {
        recipientId: conversation.userId,
        content: text,
        resources: files,
      }

      // Send message via API
      const sentMessage = await messageService.sendMessage(messageData)
      console.log("[ChatArea] Message sent successfully:", sentMessage)

      // Clear the input field
      setMessage("")

      // Force scroll to bottom after sending (user expects to see their message)
      setIsUserNearBottom(true)
      
      // Multiple scroll attempts to ensure it works
      setTimeout(() => {
        scrollToBottom("smooth")
      }, 100)
      
      setTimeout(() => {
        scrollToBottom("auto")
      }, 300)

      // The message will be received via SignalR and automatically added to the UI
    } catch (error) {
      console.error("[ChatArea] Error sending message:", error)
      alert("Failed to send message. Please try again.")
    } finally {
      setIsSending(false)
    }
  }

  // Handle loading more messages (infinity scroll)
  const handleLoadMore = async (): Promise<boolean> => {
    if (!conversation.userId) {
      console.error("No user ID for loading more messages")
      return false
    }

    console.log("[ChatArea] Loading more messages for user:", conversation.userId)
    return await loadMoreMessages(conversation.userId)
  }

  // Handle key press for sending message
  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey && !isSending) {
      e.preventDefault()
      handleSendMessage(message)
    }
  }

  // Simplified handlers
  const handleMessageRead = async (messageId: string) => {
    console.log(`Message ${messageId} read (handled by SignalR)`)
  }

  const handleLoadPrevious = async () => {
    console.log("Load previous messages (not supported)")
    return false
  }

  return (
    <div className={`${!showConversationList ? "flex" : "hidden"} md:flex flex-col flex-1 bg-white h-full`}>
      <ChatHeader conversation={conversation} onBackClick={onBackClick} />

      <div className="flex-1 overflow-hidden flex flex-col">
        <MessageList
          messages={conversation.messages || []}
          conversationName={conversation.name}
          conversationAvatar={conversation.avatar}
          messagesEndRef={messagesEndRef}
          scrollContainerRef={scrollContainerRef}
          onMessageRead={handleMessageRead}
          pagination={currentPagination}
          onLoadMore={handleLoadMore}
          onLoadPrevious={handleLoadPrevious}
          onScroll={handleScroll}
        />
      </div>

      <MessageInput
        message={message}
        setMessage={setMessage}
        onSendMessage={handleSendMessage}
        onKeyPress={handleKeyPress}
        disabled={isSending}
      />
    </div>
  )
}
