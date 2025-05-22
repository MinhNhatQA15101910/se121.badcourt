"use client"

import type React from "react"
import { useState, useRef, useEffect } from "react"
import { useSession } from "next-auth/react"
import ChatHeader from "./chat-header"
import MessageList from "./message-list"
import MessageInput from "./message-input"
import type { ConversationType, MessageType, SignalRMessage } from "@/lib/types"
import { startMessageConnection, stopMessageConnection, sendMessage } from "@/services/signalRService"

interface ChatAreaProps {
  conversation: ConversationType
  showConversationList: boolean
  onBackClick: () => void
  onSendMessage: (message: string, imageUrl?: string) => void
}

export default function ChatArea({ conversation, showConversationList, onBackClick, onSendMessage }: ChatAreaProps) {
  const { data: session } = useSession()
  const [message, setMessage] = useState("")
  const messagesEndRef = useRef<HTMLDivElement>(null)

  // Scroll to bottom of messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }, [conversation.messages])

  // Connect to SignalR when conversation changes
  useEffect(() => {
    // Make sure both userId and session exist
    if (!session?.user?.id) return

    // Ensure userId is a string
    const userId = "a3e1f5b2-7c0d-4d89-a5f3-8b2f6a3e9c1d"
    if (!userId || typeof userId !== "string") return

    const connectToSignalR = async () => {
      try {
        await startMessageConnection(userId, {
          onReceiveMessageThread: (messages) => {
            console.log("Received message thread:", messages)
            // Handle message thread if needed
          },
          onNewMessage: (message: SignalRMessage) => {
            console.log("New message received:", message)

            // Convert SignalR message to our message format
            const newMessage: MessageType = {
              id: message.id,
              text: message.content,
              time: new Date(message.messageSent).toLocaleTimeString([], {
                hour: "2-digit",
                minute: "2-digit",
              }),
              sent: message.senderId === session.user.id,
              senderId: message.senderId,
              recipientId: message.recipientId,
            }

            // Add message to conversation
            onSendMessage(newMessage.text)
          },
        })
      } catch (error) {
        console.error("Error connecting to SignalR:", error)
      }
    }

    connectToSignalR()

    // Disconnect when component unmounts or conversation changes
    return () => {
      // Ensure userId is a string before calling stopMessageConnection
      if (userId && typeof userId === "string") {
        stopMessageConnection(userId)
      }
    }
  }, [conversation.userId, session?.user?.id, onSendMessage])

  // Handle sending a message
  const handleSendMessage = async (text: string, imageUrl?: string) => {
    if (text.trim() === "" && !imageUrl) return

    // Ensure userId is a string
    const userId = conversation.userId

    // Send message via SignalR if we have a userId
    if (userId && typeof userId === "string" && session?.user?.id) {
      const success = await sendMessage(userId, text)
      if (success) {
        // Clear the input field
        setMessage("")
      } else {
        console.error("Failed to send message via SignalR")
        // Fallback to regular message sending
        onSendMessage(text, imageUrl)
        setMessage("")
      }
    } else {
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
