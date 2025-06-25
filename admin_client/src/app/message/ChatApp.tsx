"use client"

import { useState, useEffect } from "react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Search, MessageCircle, Settings, Users } from "lucide-react"
import ChatArea from "@/app/message/components/chat/chat-area"
import { SignalRProvider, useSignalR } from "@/contexts/signalr-context"
import type { ConversationType, MessageType } from "@/lib/types"


function ChatAppContent() {
  const [conversations, setConversations] = useState<ConversationType[]>([]);
const [selectedConversation, setSelectedConversation] = useState<ConversationType | null>(null);
  const [showConversationList, setShowConversationList] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")

  const { onlineUsers, connectionStates, latestMessages, messageThreads } = useSignalR()

  // Update conversations with online status
  useEffect(() => {
    setConversations((prev) =>
      prev.map((conv) => ({
        ...conv,
        online: conv.isGroup ? true : onlineUsers.includes(conv.userId || ""),
      })),
    )
  }, [onlineUsers])

  // Update conversations with latest messages from SignalR
  useEffect(() => {
    setConversations((prev) =>
      prev.map((conv) => {
        const key = conv.groupId || conv.userId
        const latestMessage = key ? latestMessages[key] : null

        if (latestMessage) {
          return {
            ...conv,
            lastMessage: latestMessage.content,
            time: new Date(latestMessage.messageSent).toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
            }),
          }
        }
        return conv
      }),
    )
  }, [latestMessages])

  // Update conversations with messages from message threads
  useEffect(() => {
    setConversations((prev) =>
      prev.map((conv) => {
        if (conv.isGroup && conv.groupId) {
          const thread = messageThreads[conv.groupId]
          if (thread && thread.items.length > 0) {
            const uiMessages: MessageType[] = thread.items.map((msg) => ({
              id: msg.id,
              text: msg.content,
              time: new Date(msg.messageSent).toLocaleTimeString([], {
                hour: "2-digit",
                minute: "2-digit",
              }),
              sent: msg.senderId === "current-user", // Replace with actual current user ID
              senderId: msg.senderId,
              recipientId: msg.receiverId,
              senderUsername: msg.senderUsername,
              senderImageUrl: msg.senderImageUrl,
              resources: msg.resources,
              groupId: msg.groupId,
            }))

            return {
              ...conv,
              messages: uiMessages,
            }
          }
        }
        return conv
      }),
    )
  }, [messageThreads])

  const handleSendMessage = (text: string, imageUrl?: string) => {
    if (!selectedConversation) return

    const newMessage: MessageType = {
      id: Date.now().toString(),
      text,
      time: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
      sent: true,
      senderId: "current-user",
      recipientId: selectedConversation.userId || "",
      imageUrl,
      groupId: selectedConversation.groupId,
    }

    // Update conversations with new message (optimistic update)
    setConversations((prev) =>
      prev.map((conv) =>
        conv.id === selectedConversation.id
          ? {
              ...conv,
              messages: [...conv.messages, newMessage],
              lastMessage: text || "Image",
              time: "now",
            }
          : conv,
      ),
    )

    // Update selected conversation
    setSelectedConversation((prev) =>
      prev
        ? {
            ...prev,
            messages: [...prev.messages, newMessage],
            lastMessage: text || "Image",
            time: "now",
          }
        : null,
    )
  }

  const handleConversationSelect = (conversation: ConversationType) => {
    setSelectedConversation(conversation)
    setShowConversationList(false)
  }

  const handleBackClick = () => {
    setShowConversationList(true)
  }

  const filteredConversations = conversations.filter((conv) =>
    conv.name.toLowerCase().includes(searchQuery.toLowerCase()),
  )

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <div
        className={`${showConversationList ? "flex" : "hidden"} md:flex flex-col w-full md:w-80 bg-white border-r border-gray-200`}
      >
        {/* Header */}
        <div className="p-4 border-b border-gray-200">
          <div className="flex items-center justify-between mb-4">
            <h1 className="text-xl font-semibold text-gray-800">Messages</h1>
            <div className="flex gap-2">
              <Button variant="ghost" size="icon" className="rounded-full hover:bg-gray-100">
                <Users className="w-5 h-5 text-gray-500" />
              </Button>
              <Button variant="ghost" size="icon" className="rounded-full hover:bg-gray-100">
                <Settings className="w-5 h-5 text-gray-500" />
              </Button>
            </div>
          </div>

          {/* Connection Status */}
          <div className="mb-4 text-xs text-gray-500">
            <div className="flex gap-2">
              <span
                className={`w-2 h-2 rounded-full ${connectionStates.presence ? "bg-green-500" : "bg-red-500"}`}
              ></span>
              <span>Presence: {connectionStates.presence ? "Connected" : "Disconnected"}</span>
            </div>
            <div className="flex gap-2">
              <span
                className={`w-2 h-2 rounded-full ${connectionStates.message ? "bg-green-500" : "bg-red-500"}`}
              ></span>
              <span>Messages: {connectionStates.message ? "Connected" : "Disconnected"}</span>
            </div>
            <div className="flex gap-2">
              <span className={`w-2 h-2 rounded-full ${connectionStates.group ? "bg-green-500" : "bg-red-500"}`}></span>
              <span>Groups: {connectionStates.group ? "Connected" : "Disconnected"}</span>
            </div>
          </div>

          {/* Search */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            <Input
              type="text"
              placeholder="Search conversations..."
              className="pl-10 bg-gray-50 border-gray-200 focus-visible:ring-green-500"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>

        {/* Conversations List */}
        <div className="flex-1 overflow-y-auto">
          {filteredConversations.map((conversation) => (
            <div
              key={conversation.id}
              className={`p-4 border-b border-gray-100 cursor-pointer hover:bg-gray-50 transition-colors ${
                selectedConversation?.id === conversation.id ? "bg-green-50 border-r-2 border-r-green-500" : ""
              }`}
              onClick={() => handleConversationSelect(conversation)}
            >
              <div className="flex items-center gap-3">
                <div className="relative">
                  <Avatar className="w-12 h-12 border border-gray-200">
                    <AvatarImage src={conversation.avatar || "/placeholder.svg"} alt={conversation.name} />
                    <AvatarFallback>{conversation.name.charAt(0)}</AvatarFallback>
                  </Avatar>
                  {conversation.online && !conversation.isGroup && (
                    <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-green-500 border-2 border-white rounded-full"></div>
                  )}
                  {conversation.isGroup && (
                    <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-blue-500 border-2 border-white rounded-full flex items-center justify-center">
                      <Users className="w-2 h-2 text-white" />
                    </div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <h3 className="font-medium text-gray-800 truncate">
                      {conversation.name}
                      {conversation.isGroup && <span className="text-xs text-gray-500 ml-1">(Group)</span>}
                    </h3>
                    <span className="text-xs text-gray-500">{conversation.time}</span>
                  </div>
                  <div className="flex items-center justify-between mt-1">
                    <p className="text-sm text-gray-600 truncate">{conversation.lastMessage}</p>
                    {conversation.unread > 0 && (
                      <Badge className="bg-green-500 hover:bg-green-600 text-white text-xs px-2 py-1 rounded-full">
                        {conversation.unread}
                      </Badge>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Chat Area */}
      {selectedConversation ? (
        <ChatArea
          conversation={selectedConversation}
          showConversationList={showConversationList}
          onBackClick={handleBackClick}
          onSendMessage={handleSendMessage}
        />
      ) : (
        <div className="hidden md:flex flex-1 items-center justify-center bg-gray-50">
          <div className="text-center">
            <MessageCircle className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <h2 className="text-xl font-medium text-gray-500 mb-2">Select a conversation</h2>
            <p className="text-gray-400">Choose a conversation from the sidebar to start chatting</p>
          </div>
        </div>
      )}
    </div>
  )
}

export default function ChatApp() {
  return (
    <SignalRProvider>
      <ChatAppContent />
    </SignalRProvider>
  )
}
