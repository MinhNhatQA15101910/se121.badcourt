"use client"

import { useState, useEffect, useCallback } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Search, MessageCircle, RefreshCw, Users, ChevronDown } from "lucide-react"
import ChatArea from "@/app/message/components/chat/chat-area"
import { useSignalR } from "@/contexts/signalr-context"
import { useSession } from "next-auth/react"
import type { ConversationType, MessageType, SignalRGroup } from "@/lib/types"
import ConversationItem from "./components/conversation/conversation-item"
import { useMemo } from "react"
import { useDebounce } from "@/hooks/use-debounce"
import { groupService } from "@/services/groupService"

export default function ChatApp() {
  const [selectedGroup, setSelectedGroup] = useState<SignalRGroup | null>(null)
  const [selectedOtherUserId, setSelectedOtherUserId] = useState<string | null>(null)
  const [showConversationList, setShowConversationList] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [searchResults, setSearchResults] = useState<SignalRGroup[]>([])
  const [isSearching, setIsSearching] = useState(false)
  const [readConversations, setReadConversations] = useState<Map<string, number>>(new Map())

  const { data: session } = useSession()
  const debouncedSearchQuery = useDebounce(searchQuery, 300) // Debounce search

  const { messageThreads, joinedGroups, groupsPagination, loadMoreGroups, onlineUsers, connectToUserForChat } =
    useSignalR()

  // Handle server-side search
  const handleSearch = useCallback(async (query: string) => {
    if (!query.trim()) {
      setSearchResults([])
      setIsSearching(false)
      return
    }

    setIsSearching(true)
    try {
      const response = await groupService.getGroups({
        search: query,
        pageSize: 50, // Get more results for search
        pageNumber: 1,
      })

      setSearchResults(response.items || [])
    } catch (error) {
      console.error("Search failed:", error)
      setSearchResults([])
    } finally {
      setIsSearching(false)
    }
  }, [])

  // Trigger search when debounced query changes
  useEffect(() => {
    handleSearch(debouncedSearchQuery)
  }, [debouncedSearchQuery, handleSearch])

  // Debug: Log message threads when they change
  useEffect(() => {
    console.log("[ChatApp] Message threads updated:", messageThreads)
    console.log("[ChatApp] Selected other user ID:", selectedOtherUserId)
    if (selectedOtherUserId && messageThreads[selectedOtherUserId]) {
      console.log("[ChatApp] Messages for selected user:", messageThreads[selectedOtherUserId])
    }
  }, [messageThreads, selectedOtherUserId])

  // Debug: Log groups when they change
  useEffect(() => {
    console.log("[ChatApp] Joined groups updated:", joinedGroups)
    console.log("[ChatApp] Groups count:", joinedGroups.length)
  }, [joinedGroups])

  // Mark conversation as read (UI only)
  const markConversationAsRead = (groupId: string) => {
    const currentTimestamp = Date.now()
    setReadConversations((prev) => new Map([...prev, [groupId, currentTimestamp]]))
    console.log(
      `[ChatApp] Marked conversation ${groupId} as read at ${new Date(currentTimestamp).toISOString()} (UI only)`,
    )
  }

  // Check if conversation should show unread indicator
  const isConversationUnread = (group: SignalRGroup): boolean => {
    const lastMessage = group.lastMessage
    if (!lastMessage || lastMessage.senderId === session?.user?.id) {
      return false // No message or message from current user
    }

    // If message is already read on server
    if (lastMessage.dateRead) {
      return false
    }

    // Check if we have marked this conversation as read locally
    const lastReadTimestamp = readConversations.get(group.id)
    if (lastReadTimestamp) {
      const messageTimestamp = new Date(lastMessage.messageSent).getTime()
      // If message is older than our last read timestamp, it's read
      if (messageTimestamp <= lastReadTimestamp) {
        return false
      }
    }

    // Message is unread
    return true
  }

  // Convert selected SignalR group to conversation format for ChatArea compatibility
  const selectedConversation: ConversationType | null = useMemo(() => {
    if (selectedGroup && selectedOtherUserId) {
      return {
        id: selectedGroup.id,
        name: selectedGroup.users.find((user) => user.id !== session?.user?.id)?.username || "Unknown User",
        avatar:
          selectedGroup.users.find((user) => user.id !== session?.user?.id)?.photoUrl ||
          "/placeholder.svg?height=48&width=48",
        lastMessage: selectedGroup.lastMessage?.content || "No messages yet",
        time: selectedGroup.lastMessage
          ? new Date(selectedGroup.lastMessage.messageSent).toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
            })
          : new Date(selectedGroup.updatedAt).toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
            }),
        unread: 0,
        online: onlineUsers.includes(selectedOtherUserId),
        starred: false,
        messages:
          messageThreads[selectedOtherUserId]?.items.map((msg): MessageType => {
            console.log("[ChatApp] Converting message:", msg)
            return {
              id: msg.id,
              text: msg.content,
              time: new Date(msg.messageSent).toLocaleTimeString([], {
                hour: "2-digit",
                minute: "2-digit",
              }),
              sent: msg.senderId === session?.user?.id,
              senderId: msg.senderId,
              recipientId: msg.receiverId,
              senderUsername: msg.senderUsername,
              senderImageUrl: msg.senderImageUrl,
              resources: msg.resources,
              groupId: msg.groupId,
              imageUrl: msg.resources?.find((r) => r.fileType === "image")?.url,
            }
          }) || [],
        groupId: selectedGroup.id,
        isGroup: true,
        users: selectedGroup.users,
        userId: selectedOtherUserId, // This is the recipient ID for sending messages
      }
    }
    return null
  }, [selectedGroup, selectedOtherUserId, onlineUsers, messageThreads, session])

  // Debug: Log selected conversation
  useEffect(() => {
    console.log("[ChatApp] Selected conversation:", selectedConversation)
    if (selectedConversation) {
      console.log("[ChatApp] Conversation messages:", selectedConversation.messages)
    }
  }, [selectedConversation])

  const handleSendMessage = async (text: string) => {
    console.log("Message would be sent:", text)
    // This is now handled by ChatArea component via messageService
  }

  const handleGroupSelect = async (group: SignalRGroup, otherUserId: string | null) => {
    if (!otherUserId) {
      console.error("Cannot find other user ID")
      return
    }

    console.log(`[ChatApp] Selecting group: ${group.id}, otherUserId: ${otherUserId}`)

    // Mark conversation as read when clicked (UI only)
    markConversationAsRead(group.id)

    // Set selected group and other user ID first
    setSelectedGroup(group)
    setSelectedOtherUserId(otherUserId)

    // Connect to MessageHub with other user ID
    const connected = await connectToUserForChat(otherUserId)

    if (connected) {
      setShowConversationList(false)
      console.log(`[ChatApp] Successfully connected and selected conversation`)
    } else {
      console.error("Failed to connect to MessageHub")
      // Reset selection if connection failed
      setSelectedGroup(null)
      setSelectedOtherUserId(null)
    }
  }

  const handleBackClick = () => {
    setShowConversationList(true)
  }

  // Handle infinity scroll for groups
  const handleLoadMoreGroups = async () => {
    if (groupsPagination.hasNextPage && !groupsPagination.isLoading) {
      console.log("[ChatApp] Loading more groups...")
      await loadMoreGroups()
    }
  }

  // Determine which groups to display
  const displayGroups = searchQuery.trim() ? searchResults : joinedGroups

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <div
        className={`${
          showConversationList ? "flex" : "hidden"
        } md:flex flex-col w-full md:w-80 bg-white border-r border-gray-200`}
      >
        {/* Search */}
        <div className="p-4 border-b border-gray-200">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            <Input
              type="text"
              placeholder="Search people in groups..."
              className="pl-10 bg-gray-50 border-gray-200 focus-visible:ring-green-500"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
            {isSearching && (
              <RefreshCw className="absolute right-3 top-1/2 transform -translate-y-1/2 w-4 h-4 animate-spin text-gray-400" />
            )}
          </div>
        </div>

        {/* Groups List */}
        <div className="flex-1 overflow-y-auto">
          {isSearching && searchQuery.trim() ? (
            <div className="flex items-center justify-center p-8">
              <RefreshCw className="w-6 h-6 animate-spin text-gray-400" />
              <span className="ml-2 text-gray-500">Searching...</span>
            </div>
          ) : displayGroups.length > 0 ? (
            <>
              {displayGroups.map((group) => (
                <ConversationItem
                  key={group.id}
                  group={group}
                  isActive={selectedGroup?.id === group.id}
                  onClick={(otherUserId) => handleGroupSelect(group, otherUserId)}
                  onlineUsers={onlineUsers}
                  isUnread={isConversationUnread(group)}
                />
              ))}

              {/* Load More Button - Only show for regular groups, not search results */}
              {!searchQuery.trim() && groupsPagination.hasNextPage && (
                <div className="p-4">
                  <Button
                    variant="outline"
                    className="w-full bg-transparent"
                    onClick={handleLoadMoreGroups}
                    disabled={groupsPagination.isLoading}
                  >
                    {groupsPagination.isLoading ? (
                      <>
                        <RefreshCw className="w-4 h-4 animate-spin mr-2" />
                        Loading...
                      </>
                    ) : (
                      <>
                        <ChevronDown className="w-4 h-4 mr-2" />
                        Load More ({groupsPagination.totalCount - joinedGroups.length} remaining)
                      </>
                    )}
                  </Button>
                </div>
              )}
            </>
          ) : (
            <div className="flex flex-col items-center justify-center p-8 text-center">
              <Users className="w-12 h-12 text-gray-300 mb-3" />
              <h3 className="font-medium text-gray-500 mb-1">
                {searchQuery.trim() ? "No results found" : "No conversations found"}
              </h3>
              <p className="text-sm text-gray-400">
                {searchQuery.trim()
                  ? `No groups found for "${searchQuery}"`
                  : "You haven't started any conversations yet"}
              </p>
            </div>
          )}
        </div>

        {/* Pagination Info */}
        {!searchQuery.trim() && groupsPagination.totalCount > 0 && (
          <div className="p-3 border-t border-gray-200 bg-gray-50">
            <div className="text-xs text-gray-500 text-center">
              Showing {displayGroups.length} of {groupsPagination.totalCount} conversations
              {groupsPagination.totalPages > 1 && (
                <span>
                  {" "}
                  • Page {groupsPagination.currentPage} of {groupsPagination.totalPages}
                </span>
              )}
            </div>
          </div>
        )}

        {/* Search Results Info */}
        {searchQuery.trim() && searchResults.length > 0 && (
          <div className="p-3 border-t border-gray-200 bg-gray-50">
            <div className="text-xs text-gray-500 text-center">
              Found {searchResults.length} results for &quot;{searchQuery}&quot;
            </div>
          </div>
        )}
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
