/* eslint-disable react-hooks/exhaustive-deps */
"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import { MessageCircle, UserCheck, UserX, Mail, Clock } from "lucide-react"
import Image from "next/image"
import { userService, type User as UserServiceUser } from "@/services/userService"
import { useRouter } from "next/navigation"

interface UserDetailModalProps {
  userId: string | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onUserUpdate?: (userId: string, newState: "Active" | "Locked") => void
}

export function UserDetailModal({ userId, open, onOpenChange, onUserUpdate }: UserDetailModalProps) {
  const [user, setUser] = useState<UserServiceUser | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [updating, setUpdating] = useState(false)
  const [chatLoading, setChatLoading] = useState(false)

  const router = useRouter()

  useEffect(() => {
    if (userId && open) {
      fetchUserDetails()
    }
  }, [userId, open])

  const fetchUserDetails = async () => {
    if (!userId) return
    try {
      setLoading(true)
      setError(null)
      const userData = await userService.getUserById(userId)
      setUser(userData)
    } catch (err) {
      setError(`Failed to load user details: ${err instanceof Error ? err.message : "Unknown error"}`)
    } finally {
      setLoading(false)
    }
  }

  const handleChatWithUser = async () => {
    if (!user) return

    try {
      setChatLoading(true)

      // 1. Lưu thông tin user cần chat vào localStorage
      const chatData = {
        userId: user.id,
        username: user.username,
        photoUrl: user.photoUrl,
        timestamp: Date.now(),
      }

      localStorage.setItem("pendingChatUser", JSON.stringify(chatData))
      console.log("[UserDetailModal] Saved pending chat user to localStorage:", chatData)

      // 2. Đóng modal
      onOpenChange(false)

      // 3. Chuyển đến trang message
      router.push("/message")

      // 4. Dispatch custom event để thông báo cho ChatApp
      window.dispatchEvent(
        new CustomEvent("initiateChatWithUser", {
          detail: chatData,
        }),
      )
    } catch (error) {
      console.error("Error starting chat:", error)
      alert("Failed to start chat. Please try again.")
    } finally {
      setChatLoading(false)
    }
  }

  const handleToggleUserState = async () => {
    if (!user) return

    try {
      setUpdating(true)
      const newState: "Active" | "Locked" = user.state === "Active" ? "Locked" : "Active"

      if (newState === "Locked") {
        await userService.lockUser(user.id)
      } else {
        await userService.unlockUser(user.id)
      }

      setUser({ ...user, state: newState })
      onUserUpdate?.(user.id, newState)
    } catch (err) {
      console.error("Failed to update user state:", err)
    } finally {
      setUpdating(false)
    }
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  const formatLastOnline = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / 60000)

    if (diffInMinutes < 1) return "Just now"
    if (diffInMinutes < 60) return `${diffInMinutes} minutes ago`
    if (diffInMinutes < 1440) return `${Math.floor(diffInMinutes / 60)} hours ago`
    return `${Math.floor(diffInMinutes / 1440)} days ago`
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="text-xl font-semibold text-gray-900">User Details</DialogTitle>
        </DialogHeader>

        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
              <p className="mt-2 text-gray-600">Loading user details...</p>
            </div>
          </div>
        ) : error || !user ? (
          <div className="flex items-center justify-center h-64">
            <div className="text-center">
              <p className="text-red-600 mb-4">{error || "User not found"}</p>
              <Button onClick={fetchUserDetails} variant="outline">
                Try Again
              </Button>
            </div>
          </div>
        ) : (
          <div className="bg-white space-y-6">
            {/* Profile */}
            <div className="flex items-center space-x-4">
              <div className="h-16 w-16 rounded-full overflow-hidden shadow-sm border">
                <Image
                  src={user.photoUrl || "/placeholder.svg?height=64&width=64"}
                  alt={user.username}
                  width={64}
                  height={64}
                  className="object-cover w-full h-full"
                />
              </div>

              <div className="flex-1 space-y-2">
                <div className="flex items-center space-x-3">
                  <h3 className="text-lg font-semibold text-gray-900">{user.username}</h3>
                  <Badge variant="outline" className="bg-blue-100 text-blue-800 border-blue-300">
                    {user.roles[0] || "N/A"}
                  </Badge>
                </div>

                <div className="flex items-center space-x-2 text-gray-600 text-sm">
                  <Mail className="h-4 w-4" />
                  <span>{user.email}</span>
                </div>

                <div className="flex items-center space-x-2 text-gray-600 text-sm">
                  <Clock className="h-4 w-4" />
                  <span>Last online: {formatLastOnline(user.lastOnlineAt)}</span>
                </div>
              </div>

              <div>
                <span
                  className={`px-3 py-1 rounded-full text-xs font-semibold border ${
                    user.state === "Active"
                      ? "bg-green-100 text-green-800 border-green-300"
                      : "bg-red-100 text-red-800 border-red-300"
                  }`}
                >
                  {user.state}
                </span>
              </div>
            </div>

            <Separator />

            {/* Info */}
            <div className="space-y-4">
              <h4 className="text-sm font-medium text-gray-900">Information</h4>
              <div className="space-y-3">
                <InfoRow label="User ID" value={<code>{user.id}</code>} />
                <InfoRow label="Username" value={user.username} />
                <InfoRow label="Email" value={user.email} />
                <InfoRow label="Account Created" value={formatDate(user.createdAt)} />
                <InfoRow label="Last Online" value={formatDate(user.lastOnlineAt)} />
              </div>
            </div>

            {/* Actions */}
            <div className="flex justify-end space-x-3 pt-4">
              <Button
                variant="outline"
                onClick={handleChatWithUser}
                disabled={chatLoading}
                className="flex items-center space-x-2 bg-[#D7FAE0] hover:bg-[#D7FAE0]/80 border-[#23C16B] text-[#23C16B] font-medium"
              >
                {chatLoading ? (
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-[#23C16B]"></div>
                ) : (
                  <MessageCircle className="h-4 w-4" />
                )}
                <span>{chatLoading ? "Opening Chat..." : "Chat with User"}</span>
              </Button>

              {user.state === "Active" ? (
                <Button
                  onClick={handleToggleUserState}
                  disabled={updating}
                  className="flex items-center space-x-2 font-medium bg-red-600 hover:bg-red-700 text-white"
                >
                  {updating ? (
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  ) : (
                    <UserX className="h-4 w-4" />
                  )}
                  <span>{updating ? "Locking..." : "Lock User"}</span>
                </Button>
              ) : (
                <Button
                  onClick={handleToggleUserState}
                  disabled={updating}
                  className="flex items-center space-x-2 font-medium bg-green-600 hover:bg-green-700 text-white"
                >
                  {updating ? (
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  ) : (
                    <UserCheck className="h-4 w-4" />
                  )}
                  <span>{updating ? "Activating..." : "Activate User"}</span>
                </Button>
              )}
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex justify-between items-center">
      <span className="text-sm text-gray-600">{label}:</span>
      <span className="text-sm font-medium">{value}</span>
    </div>
  )
}
