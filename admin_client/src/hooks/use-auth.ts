"use client"

import { useSession } from "next-auth/react"
import type { User } from "@/lib/types" // Đảm bảo đường dẫn import đúng

export function useAuth() {
  const { data: session, status } = useSession()

  const user: Partial<User> = {
    id: session?.user.id || undefined,
    username: session?.user.username || undefined,
    email: session?.user.email || undefined,
    roles: session?.user.roles || [],
    photoUrl: session?.user.photoUrl || undefined,
    isOnline: session?.user.isOnline,
    verified: session?.user.verified,
  }

  return {
    user,
    token: session?.token || undefined,
    isAuthenticated: !!session,
    isLoading: status === "loading",
    isAdmin: session?.user.roles?.includes("Admin") || false,
  }
}
