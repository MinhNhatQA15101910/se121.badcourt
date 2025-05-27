"use client"

import { useState, useEffect } from "react"
import { useSession } from "next-auth/react"
import { conversations } from "@/lib/data"
import type { ConversationType, MessageType } from "@/lib/types"
import { startPresenceConnection } from "@/services/signalRService"
import ConversationList from "./components/conversation/conversation-list"
import ChatArea from "./components/chat/chat-area"

export default function ChatPage() {
  const { data: session } = useSession()
  const [allConversations, setAllConversations] = useState<ConversationType[]>(conversations)
  const [activeConversationId, setActiveConversationId] = useState<number>(1)
  const [showConversationList, setShowConversationList] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [onlineUsers, setOnlineUsers] = useState<string[]>([])

  const activeConversation = allConversations.find((conv) => conv.id === activeConversationId) || allConversations[0]

  // Connect to presence hub when component mounts
  useEffect(() => {
    if (!session?.user?.id) return

    const connectToPresenceHub = async () => {
      try {
        await startPresenceConnection({
          onUserOnline: (userId) => {
            console.log(`User ${userId} is online`)
            setOnlineUsers((prev) => [...prev.filter((id) => id !== userId), userId])

            // Update conversation online status
            setAllConversations((prevConversations) =>
              prevConversations.map((conv) =>
                typeof conv.userId === "string" && conv.userId === userId ? { ...conv, online: true } : conv,
              ),
            )
          },
          onUserOffline: (userId) => {
            console.log(`User ${userId} is offline`)
            setOnlineUsers((prev) => prev.filter((id) => id !== userId))

            // Update conversation online status
            setAllConversations((prevConversations) =>
              prevConversations.map((conv) =>
                typeof conv.userId === "string" && conv.userId === userId ? { ...conv, online: false } : conv,
              ),
            )
          },
          onOnlineUsers: (users) => {
            console.log("Online users:", users)
            setOnlineUsers(users)

            // Update all conversations with online status
            setAllConversations((prevConversations) =>
              prevConversations.map((conv) => ({
                ...conv,
                online: typeof conv.userId === "string" && users.includes(conv.userId) ? true : conv.online,
              })),
            )
          },
        })
      } catch (error) {
        console.error("Error connecting to presence hub:", error)
      }
    }

    connectToPresenceHub()

    // Cleanup function
    return () => {
      // We don't disconnect here anymore, as SignalRManager handles this
    }
  }, [session?.user?.id])

  // Add user IDs to conversations for demo purposes
  useEffect(() => {
    // This would normally come from your API
    const conversationsWithUserIds = allConversations.map((conv, index) => ({
      ...conv,
      userId: `user-${index + 1}`, // Fake user IDs
    }))

    setAllConversations(conversationsWithUserIds)
  }, [])

  const handleSelectConversation = (id: number) => {
    setActiveConversationId(id)

    // Mark conversation as read when selected
    setAllConversations(allConversations.map((conv) => (conv.id === id ? { ...conv, unread: 0 } : conv)))

    // On mobile, hide the conversation list when a conversation is selected
    if (window.innerWidth < 768) {
      setShowConversationList(false)
    }
  }

  const handleBackClick = () => {
    setShowConversationList(true)
  }

  const handleSendMessage = (text: string, imageUrl?: string) => {
    if (!activeConversation) return

    const newMessage: MessageType = {
      id: Date.now(),
      text,
      time: "Today, " + new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
      sent: true,
      imageUrl,
    }

    const updatedConversation = {
      ...activeConversation,
      lastMessage: text || "Sent an image",
      time: "Just now",
      messages: [...activeConversation.messages, newMessage],
    }

    setAllConversations(
      allConversations.map((conv) => (conv.id === updatedConversation.id ? updatedConversation : conv)),
    )
  }

  const handleSearchChange = (query: string) => {
    setSearchQuery(query)
  }

  // Filter conversations based on search query
  const filteredConversations = searchQuery
    ? allConversations.filter(
        (conv) =>
          conv.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
          conv.lastMessage.toLowerCase().includes(searchQuery.toLowerCase()),
      )
    : allConversations

  return (
    <div className="flex h-screen bg-white">
      <ConversationList
        conversations={filteredConversations}
        activeConversationId={activeConversationId}
        showConversationList={showConversationList}
        searchQuery={searchQuery}
        onSearchChange={handleSearchChange}
        onSelectConversation={handleSelectConversation}
      />

      {activeConversation && (
        <ChatArea
          conversation={activeConversation}
          showConversationList={showConversationList}
          onBackClick={handleBackClick}
          onSendMessage={handleSendMessage}
        />
      )}
    </div>
  )
}
