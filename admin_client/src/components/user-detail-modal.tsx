"use client"

import { useState, useEffect } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import { MessageCircle, UserCheck, UserX, Mail, Clock } from "lucide-react"
import Image from "next/image"
import { userService, type User as UserServiceUser } from "@/services/userService"

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

  useEffect(() => {
    if (userId && open) {
      fetchUserDetails()
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [userId, open])

  const fetchUserDetails = async () => {
    if (!userId) return

    try {
      setLoading(true)
      setError(null)
      const userData = await userService.getUserById(userId)
      setUser(userData)
    } catch (err) {
      console.error("Failed to fetch user details:", err)
      setError(`Failed to load user details: ${err instanceof Error ? err.message : "Unknown error"}`)
    } finally {
      setLoading(false)
    }
  }

  const handleChatWithUser = () => {
    if (user) {
      window.open(`/messages/${user.id}`, "_blank")
    }
  }

  const handleToggleUserState = async () => {
    if (!user) return

    try {
      setUpdating(true)
      const newState = user.state === "Active" ? "Locked" : "Active"

      await userService.updateUserStatus(user.id, newState)

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
    const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60))

    if (diffInMinutes < 1) return "Just now"
    if (diffInMinutes < 60) return `${diffInMinutes} minutes ago`
    if (diffInMinutes < 1440) return `${Math.floor(diffInMinutes / 60)} hours ago`
    return `${Math.floor(diffInMinutes / 1440)} days ago`
  }

  if (loading) {
    return (
      <Dialog open={open} onOpenChange={onOpenChange}>
        <DialogContent className="sm:max-w-[500px]">
          <div className="flex items-center justify-center h-64">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
              <p className="mt-2 text-gray-600">Loading user details...</p>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    )
  }

  if (error || !user) {
    return (
      <Dialog open={open} onOpenChange={onOpenChange}>
        <DialogContent className="sm:max-w-[500px]">
          <div className="flex items-center justify-center h-64">
            <div className="text-center">
              <p className="text-red-600 mb-4">{error || "User not found"}</p>
              <Button onClick={fetchUserDetails} variant="outline">
                Try Again
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    )
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="text-xl font-semibold text-gray-900">User Details</DialogTitle>
        </DialogHeader>

        <div className="bg-white">
          <div className="space-y-6">
            {/* User Profile Section */}
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
                  className={`px-3 py-1 rounded-full text-xs font-medium ${
                    user.state === "Active" ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800"
                  }`}
                >
                  {user.state}
                </span>
              </div>
            </div>

            <Separator />

            {/* User Information */}
            <div className="space-y-4">
              <h4 className="text-sm font-medium text-gray-900">Information</h4>

              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">User ID:</span>
                  <span className="text-sm font-mono bg-gray-100 px-2 py-1 rounded">{user.id}</span>
                </div>

                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Username:</span>
                  <span className="text-sm font-medium">{user.username}</span>
                </div>

                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Email:</span>
                  <span className="text-sm font-medium">{user.email}</span>
                </div>

                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Account Created:</span>
                  <span className="text-sm font-medium">{formatDate(user.createdAt)}</span>
                </div>

                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Last Online:</span>
                  <span className="text-sm font-medium">{formatDate(user.lastOnlineAt)}</span>
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex justify-end space-x-3 pt-4">
              <Button
                variant="outline"
                onClick={handleChatWithUser}
                className="flex items-center space-x-2 bg-[#D7FAE0] hover:bg-[#D7FAE0]/80 border-[#23C16B] text-[#23C16B] font-medium"
              >
                <MessageCircle className="h-4 w-4" />
                <span>Chat with User</span>
              </Button>

              <Button
                onClick={handleToggleUserState}
                disabled={updating}
                className={`flex items-center space-x-2 font-medium ${
                  user.state === "Active"
                    ? "bg-red-600 hover:bg-red-700 text-white"
                    : "bg-green-600 hover:bg-green-700 text-white"
                }`}
              >
                {updating ? (
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                ) : user.state === "Active" ? (
                  <UserX className="h-4 w-4" />
                ) : (
                  <UserCheck className="h-4 w-4" />
                )}
                <span>{updating ? "Updating..." : user.state === "Active" ? "Lock User" : "Activate User"}</span>
              </Button>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
