/* eslint-disable react-hooks/exhaustive-deps */
"use client";

import { useState, useEffect, useCallback } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Search, MessageCircle, RefreshCw, ChevronDown } from "lucide-react";
import ChatArea from "@/app/message/components/chat/chat-area";
import { useSignalR } from "@/contexts/signalr-context";
import { useSession } from "next-auth/react";
import type { ConversationType, MessageType, SignalRGroup } from "@/lib/types";
import ConversationItem from "./components/conversation/conversation-item";
import EmptySearchResult from "./components/conversation/empty-search-result";
import { useMemo } from "react";
import { useDebounce } from "@/hooks/use-debounce";
import { groupService } from "@/services/groupService";

export default function ChatApp() {
  const [selectedGroup, setSelectedGroup] = useState<SignalRGroup | null>(null);
  const [selectedOtherUserId, setSelectedOtherUserId] = useState<string | null>(
    null
  );
  const [showConversationList, setShowConversationList] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<SignalRGroup[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [readConversations, setReadConversations] = useState<
    Map<string, number>
  >(new Map());
  const [activeTab] = useState("all");
  const [isProcessingPendingChat, setIsProcessingPendingChat] = useState(false);

  const { data: session } = useSession();
  const debouncedSearchQuery = useDebounce(searchQuery, 300);

  const {
    messageThreads,
    joinedGroups,
    groupsPagination,
    loadMoreGroups,
    onlineUsers,
    connectToUserForChat,
    forceRefreshGroups,
  } = useSignalR();

  // Listen for custom event from user detail modal
  useEffect(() => {
    const handleInitiateChat = async (event: CustomEvent) => {
      const userData = event.detail;
      console.log("[ChatApp] Received initiate chat event:", userData);

      if (userData && userData.userId) {
        setIsProcessingPendingChat(true);
        await handlePendingChatUser(userData.userId, true); // true = auto enter chat
        setIsProcessingPendingChat(false);
      }
    };

    // Listen for custom event
    window.addEventListener(
      "initiateChatWithUser",
      handleInitiateChat as EventListener
    );

    // Also check localStorage on component mount
    const checkPendingChatUser = () => {
      const pendingChatData = localStorage.getItem("pendingChatUser");
      if (pendingChatData) {
        try {
          const userData = JSON.parse(pendingChatData);
          console.log(
            "[ChatApp] Found pending chat user in localStorage:",
            userData
          );

          // Check if the data is not too old (5 minutes)
          const now = Date.now();
          const dataAge = now - (userData.timestamp || 0);
          const maxAge = 5 * 60 * 1000; // 5 minutes

          if (dataAge < maxAge) {
            setIsProcessingPendingChat(true);
            handlePendingChatUser(userData.userId, true).finally(() => {
              setIsProcessingPendingChat(false);
            });
          } else {
            console.log("[ChatApp] Pending chat data is too old, ignoring");
            localStorage.removeItem("pendingChatUser");
          }
        } catch (error) {
          console.error("[ChatApp] Error parsing pending chat data:", error);
          localStorage.removeItem("pendingChatUser");
        }
      }
    };

    // Check on mount
    checkPendingChatUser();

    return () => {
      window.removeEventListener(
        "initiateChatWithUser",
        handleInitiateChat as EventListener
      );
    };
  }, []);

  // Handle pending chat user
  const handlePendingChatUser = async (
    userId: string,
    autoEnterChat = false
  ) => {
    console.log(
      `[ChatApp] Processing pending chat with user: ${userId}, autoEnter: ${autoEnterChat}`
    );

    // Wait for groups to load if not loaded yet
    let retryCount = 0;
    const maxRetries = 10;
    while (!joinedGroups.length && retryCount < maxRetries) {
      console.log(
        `[ChatApp] Waiting for groups to load... (${
          retryCount + 1
        }/${maxRetries})`
      );
      await new Promise((resolve) => setTimeout(resolve, 500));
      retryCount++;
    }

    // Tìm group chat với user này
    let targetGroup = joinedGroups.find(
      (group) =>
        group.users.some((u) => u.id === userId) && group.users.length === 2
    );

    if (targetGroup) {
      console.log(
        `[ChatApp] Found existing group for user ${userId}:`,
        targetGroup
      );
      const otherUserId = targetGroup.users.find(
        (u) => u.id !== session?.user?.id
      )?.id;

      if (otherUserId) {
        await handleGroupSelect(targetGroup, otherUserId, autoEnterChat);
        localStorage.removeItem("pendingChatUser");
        return;
      }
    }

    // Nếu không tìm thấy group, thử search từ server
    console.log(
      `[ChatApp] No existing group found, searching for user: ${userId}`
    );
    try {
      const response = await groupService.getGroups({
        pageSize: 100,
        pageNumber: 1,
      });

      targetGroup = response.items?.find(
        (group) =>
          group.users.some((u) => u.id === userId) && group.users.length === 2
      );

      if (targetGroup) {
        console.log(`[ChatApp] Found group from server search:`, targetGroup);
        const otherUserId = targetGroup.users.find(
          (u) => u.id !== session?.user?.id
        )?.id;

        if (otherUserId) {
          await handleGroupSelect(targetGroup, otherUserId, autoEnterChat);
          localStorage.removeItem("pendingChatUser");
          return;
        }
      }
    } catch (error) {
      console.error("Error searching for user:", error);
    }

    // Nếu vẫn không tìm thấy group, SignalR sẽ tự tạo group mới khi connect
    console.log(
      `[ChatApp] No existing group found, SignalR will create new group for user: ${userId}`
    );

    try {
      // Tạo temporary group object để hiển thị UI
      const tempGroup: SignalRGroup = {
        id: `temp-${userId}`, // Temporary ID
        name: `Chat with User ${userId}`,
        users: [
          {
            id: session?.user?.id || "",
            username: session?.user?.name || "",
            photoUrl: session?.user?.image || "",
          },
          {
            id: userId,
            username: "Loading...",
            photoUrl: "/placeholder.svg?height=48&width=48",
          },
        ],
        lastMessage: null,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        connections: [],
      };

      // Set temporary group và connect - SignalR sẽ tạo group thật
      setSelectedGroup(tempGroup);
      setSelectedOtherUserId(userId);

      if (autoEnterChat) {
        setShowConversationList(false);
        console.log(`[ChatApp] Auto-entered chat area with new conversation`);
      }

      // Connect to SignalR - backend sẽ tự tạo group mới
      console.log(
        `[ChatApp] Connecting to SignalR to create new group with user: ${userId}`
      );
      const connected = await connectToUserForChat(userId);

      if (connected) {
        console.log(
          `[ChatApp] Successfully connected - new group should be created by backend`
        );

        // Thêm polling để check group mới được tạo
        let pollCount = 0;
        const maxPolls = 10;
        const pollInterval = setInterval(async () => {
          pollCount++;

          // Force refresh groups
          await forceRefreshGroups();

          // Check if group exists now
          const updatedGroup = joinedGroups.find(
            (group) =>
              group.users.some((u) => u.id === userId) &&
              group.users.length === 2
          );

          if (updatedGroup) {
            console.log(`[ChatApp] Found newly created group:`, updatedGroup);
            setSelectedGroup(updatedGroup);
            clearInterval(pollInterval);
            localStorage.removeItem("pendingChatUser");
          } else if (pollCount >= maxPolls) {
            clearInterval(pollInterval);
          }
        }, 1000); // Poll every 1 second

        // Group thật sẽ được update thông qua SignalR events hoặc polling
      } else {
        console.warn("Failed to connect to SignalR for new conversation");
        // Reset nếu không connect được
        setSelectedGroup(null);
        setSelectedOtherUserId(null);
        if (autoEnterChat) {
          setShowConversationList(true);
        }
        alert("Unable to start conversation. Please try again.");
      }
    } catch (error) {
      console.error("Error creating new conversation:", error);
      alert("Error starting conversation. Please try again.");
    } finally {
      localStorage.removeItem("pendingChatUser");
    }
  };

  // Re-check pending chat when groups are loaded
  useEffect(() => {
    if (joinedGroups.length > 0 && !isProcessingPendingChat) {
      const pendingChatData = localStorage.getItem("pendingChatUser");
      if (pendingChatData) {
        try {
          const userData = JSON.parse(pendingChatData);
          setIsProcessingPendingChat(true);
          handlePendingChatUser(userData.userId, true).finally(() => {
            setIsProcessingPendingChat(false);
          });
        } catch (error) {
          console.error("[ChatApp] Error processing pending chat:", error);
          localStorage.removeItem("pendingChatUser");
        }
      }
    }
  }, [joinedGroups.length, session, isProcessingPendingChat]);

  // Handle server-side search
  const handleSearch = useCallback(async (query: string) => {
    if (!query.trim()) {
      setSearchResults([]);
      setIsSearching(false);
      return;
    }

    setIsSearching(true);
    try {
      const response = await groupService.getGroups({
        search: query,
        pageSize: 50,
        pageNumber: 1,
      });

      setSearchResults(response.items || []);
    } catch (error) {
      console.error("Search failed:", error);
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  }, []);

  // Trigger search when debounced query changes
  useEffect(() => {
    handleSearch(debouncedSearchQuery);
  }, [debouncedSearchQuery, handleSearch]);

  // Mark conversation as read (UI only)
  const markConversationAsRead = (groupId: string) => {
    const currentTimestamp = Date.now();
    setReadConversations(
      (prev) => new Map([...prev, [groupId, currentTimestamp]])
    );
    console.log(
      `[ChatApp] Marked conversation ${groupId} as read at ${new Date(
        currentTimestamp
      ).toISOString()} (UI only)`
    );
  };

  // Check if conversation should show unread indicator
  const isConversationUnread = (group: SignalRGroup): boolean => {
    const lastMessage = group.lastMessage;
    if (!lastMessage || lastMessage.senderId === session?.user?.id) {
      return false;
    }

    if (lastMessage.dateRead) {
      return false;
    }

    const lastReadTimestamp = readConversations.get(group.id);
    if (lastReadTimestamp) {
      const messageTimestamp = new Date(lastMessage.messageSent).getTime();
      if (messageTimestamp <= lastReadTimestamp) {
        return false;
      }
    }

    return true;
  };

  // Filter conversations based on active tab
  const filterConversationsByTab = (groups: SignalRGroup[]) => {
    switch (activeTab) {
      case "unread":
        return groups.filter((group) => isConversationUnread(group));
      case "starred":
        return []; // Tạm thời return empty array cho starred
      case "all":
      default:
        return groups;
    }
  };

  // Convert selected SignalR group to conversation format for ChatArea compatibility
  const selectedConversation: ConversationType | null = useMemo(() => {
    if (selectedGroup && selectedOtherUserId) {
      return {
        id: selectedGroup.id,
        name:
          selectedGroup.users.find((user) => user.id !== session?.user?.id)
            ?.username || "Unknown User",
        avatar:
          selectedGroup.users.find((user) => user.id !== session?.user?.id)
            ?.photoUrl || "/placeholder.svg?height=48&width=48",
        lastMessage: selectedGroup.lastMessage?.content || "No messages yet",
        time: selectedGroup.lastMessage
          ? new Date(selectedGroup.lastMessage.messageSent).toLocaleTimeString(
              [],
              {
                hour: "2-digit",
                minute: "2-digit",
                hour12: false, // 24-hour format
              }
            )
          : new Date(selectedGroup.updatedAt).toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
              hour12: false, // 24-hour format
            }),
        unread: 0,
        online: onlineUsers.includes(selectedOtherUserId),
        starred: false,
        messages:
          messageThreads[selectedOtherUserId]?.items.map((msg): MessageType => {
            return {
              id: msg.id,
              text: msg.content,
              time: new Date(msg.messageSent).toLocaleTimeString([], {
                hour: "2-digit",
                minute: "2-digit",
                hour12: false, // 24-hour format
              }),
              sent: msg.senderId === session?.user?.id,
              senderId: msg.senderId,
              recipientId: msg.receiverId,
              senderUsername: msg.senderUsername,
              senderImageUrl: msg.senderImageUrl,
              resources: msg.resources,
              groupId: msg.groupId,
              imageUrl: msg.resources?.find((r) => r.fileType === "image")?.url,
            };
          }) || [],
        groupId: selectedGroup.id,
        isGroup: true,
        users: selectedGroup.users,
        userId: selectedOtherUserId,
      };
    }
    return null;
  }, [
    selectedGroup,
    selectedOtherUserId,
    onlineUsers,
    messageThreads,
    session,
  ]);

  const handleSendMessage = async (text: string) => {
    console.log("Message would be sent:", text);
  };

  const handleGroupSelect = async (
    group: SignalRGroup,
    otherUserId: string | null,
    autoEnterChat = false
  ) => {
    if (!otherUserId) {
      console.error("Cannot find other user ID");
      return;
    }

    console.log(
      `[ChatApp] Selecting group: ${group.id}, otherUserId: ${otherUserId}, autoEnter: ${autoEnterChat}`
    );

    markConversationAsRead(group.id);

    // Set selected group and user immediately
    setSelectedGroup(group);
    setSelectedOtherUserId(otherUserId);

    // If auto enter chat, show chat area immediately
    if (autoEnterChat) {
      setShowConversationList(false);
      console.log(`[ChatApp] Auto-entered chat area`);
    }

    try {
      // Try to connect to SignalR in background
      console.log(
        `[ChatApp] Attempting to connect to MessageHub for user: ${otherUserId}`
      );
      const connected = await connectToUserForChat(otherUserId);

      if (connected) {
        console.log(`[ChatApp] Successfully connected to MessageHub`);
      } else {
        console.warn(
          "Failed to connect to MessageHub, but continuing with chat"
        );
        // Don't reset the selection, allow user to continue with chat
        // The messages might still work through other mechanisms
      }
    } catch (error) {
      console.error("Error connecting to MessageHub:", error);
      // Don't reset the selection, allow user to continue
      console.log("Continuing with chat despite connection error");
    }
  };

  const handleBackClick = () => {
    setShowConversationList(true);
  };

  const handleLoadMoreGroups = async () => {
    if (groupsPagination.hasNextPage && !groupsPagination.isLoading) {
      console.log("[ChatApp] Loading more groups...");
      await loadMoreGroups();
    }
  };

  const displayGroups = searchQuery.trim()
    ? searchResults
    : filterConversationsByTab(joinedGroups);

  return (
    <div className="flex h-screen bg-gray-100 overflow-hidden">
      {/* Loading overlay khi đang process pending chat */}
      {isProcessingPendingChat && (
        <div className="fixed inset-0 bg-black/20 flex items-center justify-center z-50">
          <div className="bg-white p-6 flex items-center space-x-3">
            <RefreshCw className="w-5 h-5 animate-spin text-green-600" />
            <span className="text-gray-700">Connecting to chat...</span>
          </div>
        </div>
      )}

      {/* Sidebar */}
      <div
        className={`${
          showConversationList ? "flex" : "hidden"
        } md:flex flex-col w-full md:w-80 bg-white border-r border-gray-200 h-full`}
      >
        {/* Fixed Header Section */}
        <div className="flex-shrink-0">
          {/* Search */}
          <div className="h-16 flex items-center px-4 border-b border-gray-200">
            <div className="relative w-full">
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
        </div>

        {/* Scrollable Groups List */}
        <div className="flex-1 overflow-y-auto min-h-0">
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
                  onClick={(otherUserId) =>
                    handleGroupSelect(group, otherUserId, false)
                  } // false = không auto enter
                  onlineUsers={onlineUsers}
                  isUnread={isConversationUnread(group)}
                />
              ))}

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
                        Load More (
                        {groupsPagination.totalCount - joinedGroups.length}{" "}
                        remaining)
                      </>
                    )}
                  </Button>
                </div>
              )}
            </>
          ) : (
            <EmptySearchResult searchQuery={searchQuery} />
          )}
        </div>
      </div>

      {/* Chat Area */}
      {selectedConversation ? (
        <div className="flex-1 h-full overflow-hidden">
          <ChatArea
            conversation={selectedConversation}
            showConversationList={showConversationList}
            onBackClick={handleBackClick}
            onSendMessage={handleSendMessage}
          />
        </div>
      ) : (
        <div className="hidden md:flex flex-1 items-center justify-center bg-gray-50 h-full">
          <div className="text-center">
            <MessageCircle className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <h2 className="text-xl font-medium text-gray-500 mb-2">
              Select a conversation
            </h2>
            <p className="text-gray-400">
              Choose a conversation from the sidebar to start chatting
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
