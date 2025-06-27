"use client"

import type React from "react"

import { Bell } from "lucide-react"
import { useState } from "react"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

// Define notification data type
type Notification = {
  id: string
  icon: React.ReactNode
  content: string
  time: string
  read: boolean
}

// Sample notification data
const sampleNotifications: Notification[] = [
  {
    id: "1",
    icon: <Bell className="h-4 w-4 text-blue-500" />,
    content: "You have a new message",
    time: "5 minutes ago",
    read: false,
  },
  {
    id: "2",
    icon: <Bell className="h-4 w-4 text-green-500" />,
    content: "Your order has been confirmed",
    time: "1 hour ago",
    read: false,
  },
  {
    id: "3",
    icon: <Bell className="h-4 w-4 text-yellow-500" />,
    content: "Reminder: Meeting at 3:00 PM",
    time: "2 hours ago",
    read: true,
  },
  {
    id: "4",
    icon: <Bell className="h-4 w-4 text-purple-500" />,
    content: "New system update available",
    time: "1 day ago",
    read: true,
  },
]

export function NotificationDropdown() {
  const [notifications, setNotifications] = useState<Notification[]>(sampleNotifications)
  const [open, setOpen] = useState(false)

  const unreadCount = notifications.filter((n) => !n.read).length

  const markAsRead = (id: string) => {
    setNotifications((prev) =>
      prev.map((notification) => (notification.id === id ? { ...notification, read: true } : notification)),
    )
  }

  const markAllAsRead = () => {
    setNotifications((prev) => prev.map((notification) => ({ ...notification, read: true })))
  }

  return (
    <div className="relative mr-2">
      <DropdownMenu open={open} onOpenChange={setOpen}>
        <DropdownMenuTrigger asChild>
          <Button
            variant="ghost"
            size="icon"
            className={cn(
              "relative h-7 w-7 rounded-full p-0 transition-colors hover:bg-transparent active:bg-transparent",
            )}
          >
            <span className="sr-only">Open notifications</span>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-80">
          <DropdownMenuLabel className="flex items-center justify-between">
            <span>Notifications</span>
            {unreadCount > 0 && (
              <Button
                variant="ghost"
                size="sm"
                className="h-auto text-xs text-muted-foreground hover:text-foreground"
                onClick={markAllAsRead}
              >
                Mark all as read
              </Button>
            )}
          </DropdownMenuLabel>
          <DropdownMenuSeparator />
          {notifications.length === 0 ? (
            <div className="py-4 text-center text-sm text-muted-foreground">No notifications</div>
          ) : (
            <div className="max-h-[300px] overflow-y-auto">
              {notifications.map((notification) => (
                <DropdownMenuItem
                  key={notification.id}
                  className={cn("flex cursor-pointer gap-3 p-3", !notification.read && "bg-muted/50")}
                  onClick={() => markAsRead(notification.id)}
                >
                  <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-muted">
                    {notification.icon}
                  </div>
                  <div className="flex flex-1 flex-col gap-1">
                    <div className="flex items-center justify-between">
                      <p className="text-sm">{notification.content}</p>
                      <div
                        className={cn(
                          "ml-2 flex h-2 w-2 shrink-0 rounded-full",
                          notification.read ? "bg-muted" : "bg-yellow",
                        )}
                      />
                    </div>
                    <div className="flex items-center justify-between">
                      <p className="text-xs text-muted-foreground">{notification.time}</p>
                    </div>
                  </div>
                </DropdownMenuItem>
              ))}
            </div>
          )}
          <DropdownMenuSeparator />
          <div className="p-2 text-center">
            <Button variant="outline" size="sm" className="w-full" onClick={() => setOpen(false)}>
              View all notifications
            </Button>
          </div>
        </DropdownMenuContent>
      </DropdownMenu>

      {/* Bell icon positioned absolutely */}
      <Bell className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 h-5 w-5 pointer-events-none text-white" />

      {/* Notification badge */}
      {unreadCount > 0 && (
        <span className="absolute top-0 right-0 flex h-3 w-3 items-center justify-center rounded-full bg-red-500 text-[8px] text-white pointer-events-none">
          {unreadCount}
        </span>
      )}
    </div>
  )
}

