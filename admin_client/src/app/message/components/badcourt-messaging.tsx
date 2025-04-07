"use client"

import { useState, useEffect } from "react"
import { conversationsData } from "@/lib/data"
import ConversationList from "./conversation/conversation-list"
import ChatArea from "./chat/chat-area"
import type { ConversationType } from "@/lib/types"

// Fallback conversation data in case the imported data is undefined
const fallbackConversation: ConversationType = {
  id: 1,
  name: "BadCourt Support",
  avatar: "/placeholder.svg?height=40&width=40",
  lastMessage: "Welcome to BadCourt!",
  time: "Today",
  unread: 0,
  online: true,
  isActive: true,
  starred: false,
  messages: [
    {
      id: 1,
      text: "Welcome to BadCourt! How can we help you today?",
      sent: false,
      time: "Today",
    },
  ],
}

export default function BadCourtMessaging() {
  // Ensure we have valid conversation data
  const initialConversations =
    Array.isArray(conversationsData) && conversationsData.length > 0 ? conversationsData : [fallbackConversation]

  const [conversations, setConversations] = useState(initialConversations)
  const [activeConversationId, setActiveConversationId] = useState(initialConversations[0].id)
  const [showConversationList, setShowConversationList] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")

  const activeConversation = conversations.find((conv) => conv.id === activeConversationId) || conversations[0]

  // Filter conversations based on search query
  const filteredConversations =
    searchQuery.trim() === ""
      ? conversations
      : conversations.filter(
          (conv) =>
            conv.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            conv.lastMessage.toLowerCase().includes(searchQuery.toLowerCase()),
        )

  // Handle sending a new message
  const handleSendMessage = (message: string, imageUrl?: string) => {
    // Don't send if both message and image are empty
    if (message.trim() === "" && !imageUrl) return

    // Create the new message object
    const newMessage = {
      id: activeConversation.messages.length + 1,
      text: message,
      sent: true,
      time: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
      imageUrl: imageUrl,
    }

    // Update the conversations state
    const updatedConversations = conversations.map((conv) => {
      if (conv.id === activeConversationId) {
        // Determine the last message text
        const lastMessageText = message.trim() !== "" ? message : "Sent an image"

        return {
          ...conv,
          messages: [...conv.messages, newMessage],
          lastMessage: lastMessageText,
          time: newMessage.time,
        }
      }
      return conv
    })

    setConversations(updatedConversations)
  }

  // Handle selecting a conversation
  const handleSelectConversation = (conversationId: number) => {
    setActiveConversationId(conversationId)
    setShowConversationList(false)
  }

  // Mark conversation as read when selected
  useEffect(() => {
    const updatedConversations = conversations.map((conv) => {
      if (conv.id === activeConversationId && conv.unread > 0) {
        return {
          ...conv,
          unread: 0,
        }
      }
      return conv
    })

    setConversations(updatedConversations)
  }, [activeConversationId])

  return (
    <div className="flex h-full w-full bg-[#f8fafc] overflow-hidden">
      {/* Conversation List */}
      <ConversationList
        conversations={filteredConversations}
        activeConversationId={activeConversationId}
        showConversationList={showConversationList}
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        onSelectConversation={handleSelectConversation}
      />

      {/* Chat Area */}
      <ChatArea
        conversation={activeConversation}
        showConversationList={showConversationList}
        onBackClick={() => setShowConversationList(true)}
        onSendMessage={handleSendMessage}
      />
    </div>
  )
}

