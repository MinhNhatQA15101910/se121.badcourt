"use client"

import type React from "react"
import { useState, useRef, useEffect } from "react"

import type { ConversationType, MessageType, SignalRMessage } from "@/lib/types"
import { useSignalR } from "@/contexts/signalr-context"
import ChatHeader from "@/app/message/components/chat/chat-header"
import MessageList from "@/app/message/components/chat/message-list"
import MessageInput from "@/app/message/components/chat/message-input"

interface ChatAreaProps {
  conversation: ConversationType
  showConversationList: boolean
  onBackClick: () => void
  onSendMessage: (message: string, imageUrl?: string) => void
}

export default function ChatArea({ conversation, showConversationList, onBackClick, onSendMessage }: ChatAreaProps) {
  const [message, setMessage] = useState("")
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const {
    joinGroupChat,
    sendGroupMessage,
    sendUserMessage,
    messageThreads,
    messagePagination,
    setActiveGroup,
    markAsRead,
    loadMoreMessagesForGroup,
    loadPreviousMessagesForGroup,
  } = useSignalR()

  // Scroll to bottom of messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }, [conversation.messages])

  // Handle conversation changes
  useEffect(() => {
    const handleConversationChange = async () => {
      if (conversation.isGroup && conversation.groupId) {
        // Join group and set as active
        setActiveGroup(conversation.groupId)
        await joinGroupChat(conversation.groupId)
      } else if (conversation.userId) {
        // For direct messages, we don't need to join a group
        setActiveGroup(null)
      }
    }

    handleConversationChange()

    // Cleanup when conversation changes
    return () => {
      if (conversation.isGroup && conversation.groupId) {
        // Don't leave the group immediately, just set as inactive
        setActiveGroup(null)
      }
    }
  }, [conversation.id, conversation.groupId, conversation.userId, conversation.isGroup, joinGroupChat, setActiveGroup])

  // Update conversation messages from SignalR message threads
  useEffect(() => {
    if (conversation.isGroup && conversation.groupId) {
      const thread = messageThreads[conversation.groupId]
      if (thread && thread.items.length > 0) {
        // Convert SignalR messages to UI messages
        const uiMessages: MessageType[] = thread.items.map((msg: SignalRMessage) => ({
          id: msg.id,
          text: msg.content,
          time: new Date(msg.messageSent).toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
          }),
          sent: msg.senderId === conversation.userId, // Assuming current user ID is stored in conversation
          senderId: msg.senderId,
          recipientId: msg.receiverId,
          senderUsername: msg.senderUsername,
          senderImageUrl: msg.senderImageUrl,
          resources: msg.resources,
          groupId: msg.groupId,
        }))

        // Update the conversation with new messages
        // Note: This would typically be handled by the parent component
        console.log("Updated messages from SignalR:", uiMessages)
      }
    }
  }, [messageThreads, conversation.groupId, conversation.isGroup, conversation.userId])

  // Handle sending a message
  const handleSendMessage = async (text: string, imageUrl?: string) => {
    if (text.trim() === "" && !imageUrl) return

    try {
      let success = false

      if (conversation.isGroup && conversation.groupId) {
        // Send to group
        success = await sendGroupMessage(conversation.groupId, text)
      } else if (conversation.userId) {
        // Send direct message
        success = await sendUserMessage(conversation.userId, text)
      }

      if (success) {
        // Clear the input field
        setMessage("")

        // Fallback: add message to local state if SignalR doesn't update immediately
        onSendMessage(text, imageUrl)
      } else {
        console.error("Failed to send message via SignalR")
        // Fallback to regular message sending
        onSendMessage(text, imageUrl)
        setMessage("")
      }
    } catch (error) {
      console.error("Error sending message:", error)
      // Fallback to regular message sending
      onSendMessage(text, imageUrl)
      setMessage("")
    }
  }

  // Handle key press for sending message
  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      handleSendMessage(message)
    }
  }

  // Handle message read
  const handleMessageRead = async (messageId: string) => {
    try {
      await markAsRead(messageId)
    } catch (error) {
      console.error("Failed to mark message as read:", error)
    }
  }

  // Handle load more messages
  const handleLoadMore = async () => {
    if (conversation.isGroup && conversation.groupId) {
      await loadMoreMessagesForGroup(conversation.groupId)
    }
  }

  // Handle load previous messages
  const handleLoadPrevious = async () => {
    if (conversation.isGroup && conversation.groupId) {
      await loadPreviousMessagesForGroup(conversation.groupId)
    }
  }

  // Get pagination for current conversation
  const currentPagination =
    conversation.isGroup && conversation.groupId ? messagePagination[conversation.groupId] : undefined

  return (
    <div className={`${!showConversationList ? "flex" : "hidden"} md:flex flex-col flex-1 bg-white h-full`}>
      <ChatHeader conversation={conversation} onBackClick={onBackClick} />

      <div className="flex-1 overflow-hidden flex flex-col">
        <MessageList
          messages={conversation.messages}
          conversationName={conversation.name}
          conversationAvatar={conversation.avatar}
          messagesEndRef={messagesEndRef}
          onMessageRead={handleMessageRead}
          pagination={currentPagination}
          onLoadMore={handleLoadMore}
          onLoadPrevious={handleLoadPrevious}
        />
      </div>

      <MessageInput
        message={message}
        setMessage={setMessage}
        onSendMessage={handleSendMessage}
        onKeyPress={handleKeyPress}
      />
    </div>
  )
}
