"use client"

import { useState } from "react"
import { Search, X } from "lucide-react"
import { Input } from "@/components/ui/input"
import ConversationItem from "./conversation-item"
import ConversationHeader from "./conversation-header"
import ConversationTabs from "./conversation-tabs"
import EmptySearchResult from "./empty-search-result"
import type { ConversationType } from "@/lib/types"

interface ConversationListProps {
  conversations: ConversationType[]
  activeConversationId: number
  showConversationList: boolean
  searchQuery: string
  onSearchChange: (query: string) => void
  onSelectConversation: (id: number) => void
}

export default function ConversationList({
  conversations,
  activeConversationId,
  showConversationList,
  searchQuery,
  onSearchChange,
  onSelectConversation,
}: ConversationListProps) {
  const [activeTab, setActiveTab] = useState("all")

  // Filter conversations based on active tab
  const getFilteredConversations = () => {
    if (activeTab === "unread") {
      return conversations.filter((conv) => conv.unread > 0)
    }
    if (activeTab === "starred") {
      return conversations.filter((conv) => conv.starred)
    }
    return conversations
  }

  const displayConversations = getFilteredConversations()

  return (
    <div
      className={`${showConversationList ? "flex" : "hidden"} md:flex flex-col w-full md:w-[350px] lg:w-[380px] bg-white border-r border-[#e5e7eb] shadow-sm h-full`}
    >
      <ConversationHeader />

      {/* Search */}
      <div className="p-4 pb-2">
        <div className="relative">
          <Search className="w-4 h-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
          <Input
            type="text"
            placeholder="Search messages"
            className="w-full pl-10 pr-4 py-2 bg-[#f8f9fd] border-0 rounded-lg text-sm"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
          />
          {searchQuery && (
            <button className="absolute right-3 top-1/2 transform -translate-y-1/2" onClick={() => onSearchChange("")}>
              <X className="w-4 h-4 text-gray-400" />
            </button>
          )}
        </div>
      </div>

      {/* Tabs */}
      <ConversationTabs activeTab={activeTab} onTabChange={setActiveTab} />

      {/* Conversation List */}
      <div className="flex-1 overflow-y-auto scrollbar-hide">
        {displayConversations.length === 0 ? (
          <EmptySearchResult searchQuery={searchQuery} />
        ) : (
          displayConversations.map((conversation) => (
            <ConversationItem
              key={conversation.id}
              conversation={conversation}
              isActive={Number(conversation.id) === activeConversationId}
              onClick={() => onSelectConversation(Number(conversation.id))}
            />
          ))
        )}
      </div>
    </div>
  )
}
