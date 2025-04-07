"use client"

import type React from "react"

import { useState, useRef, useEffect } from "react"
import ChatHeader from "./chat-header"
import MessageList from "./message-list"
import MessageInput from "./message-input"
import type { ConversationType } from "@/lib/types"

interface ChatAreaProps {
  conversation: ConversationType
  showConversationList: boolean
  onBackClick: () => void
  onSendMessage: (message: string, imageUrl?: string) => void
}

export default function ChatArea({ conversation, showConversationList, onBackClick, onSendMessage }: ChatAreaProps) {
  const [message, setMessage] = useState("")
  const messagesEndRef = useRef<HTMLDivElement>(null)

  // Scroll to bottom of messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }, [conversation.messages])

  // Handle sending a message
  const handleSendMessage = (text: string, imageUrl?: string) => {
    if (text.trim() === "" && !imageUrl) return
    onSendMessage(text, imageUrl)
    setMessage("")
  }

  // Handle key press for sending message
  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      handleSendMessage(message)
    }
  }

  return (
    <div className={`${!showConversationList ? "flex" : "hidden"} md:flex flex-col flex-1 bg-white h-full`}>
      <ChatHeader conversation={conversation} onBackClick={onBackClick} />

      <div className="flex-1 overflow-hidden flex flex-col">
        <MessageList
          messages={conversation.messages}
          conversationName={conversation.name}
          conversationAvatar={conversation.avatar}
          messagesEndRef={messagesEndRef}
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

