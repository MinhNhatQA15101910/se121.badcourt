import type { DefaultSession } from "next-auth"

// Mở rộng Session type để loại bỏ trường role
declare module "next-auth" {
  interface Session {
    token: string
    user: {
      id: string
      username: string
      roles: string[] // Chỉ giữ lại mảng roles
      photoUrl: string
      isOnline?: boolean
      verified?: boolean
    } & DefaultSession["user"]
  }

  interface User {
    id: string
    username: string
    email: string
    token: string
    roles: string[] // Chỉ giữ lại mảng roles
    photoUrl: string
    isOnline?: boolean
    verified?: boolean
  }
}

// Mở rộng JWT type
declare module "next-auth/jwt" {
  interface JWT {
    token: string
    id: string
    username: string
    roles: string[] // Chỉ giữ lại mảng roles
    photoUrl: string
    isOnline?: boolean
    verified?: boolean
  }
}
