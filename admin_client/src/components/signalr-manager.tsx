"use client"

import { useEffect } from "react"
import { useSession } from "next-auth/react"
import { startPresenceConnection, stopPresenceConnection } from "@/services/signalRService"

export default function SignalRManager() {
  const { data: session, status } = useSession()

  // Kết nối SignalR khi đăng nhập và ngắt kết nối khi đăng xuất
  useEffect(() => {
    // Chỉ kết nối khi đã đăng nhập
    if (status === "authenticated" && session?.user?.id) {
      console.log("User logged in, connecting to SignalR...")
      startPresenceConnection({
        onUserOnline: (userId) => {
          console.log(`User ${userId} is online`)
        },
        onUserOffline: (userId) => {
          console.log(`User ${userId} is offline`)
        },
        onOnlineUsers: (users) => {
          console.log("Online users:", users)
        },
      })
    } else if (status === "unauthenticated") {
      // Ngắt kết nối khi đăng xuất
      console.log("User logged out, disconnecting from SignalR...")
      stopPresenceConnection()
    }

    // Xử lý sự kiện đóng trang
    const handleBeforeUnload = () => {
      console.log("Page is closing, disconnecting from SignalR...")
      stopPresenceConnection()
    }

    // Đăng ký sự kiện beforeunload
    window.addEventListener("beforeunload", handleBeforeUnload)

    // Cleanup khi component unmount
    return () => {
      window.removeEventListener("beforeunload", handleBeforeUnload)
      stopPresenceConnection()
    }
  }, [status, session?.user?.id])

  // Component này không render gì cả, chỉ quản lý kết nối
  return null
}
