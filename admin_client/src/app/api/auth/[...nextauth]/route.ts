import NextAuth from "next-auth"
import CredentialsProvider from "next-auth/providers/credentials"
import type { NextAuthOptions } from "next-auth"

// Cập nhật interface JWT để loại bỏ trường role
declare module "next-auth/jwt" {
  interface JWT {
    token: string
    id: string
    username: string
    roles: string[]
    photoUrl: string
    isOnline?: boolean
    verified?: boolean
  }
}

// Extend type for credentials to include userData
interface ExtendedCredentials {
  email: string
  password: string
  userData?: string
}

export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        email: { label: "Email", type: "text" },
        password: { label: "Password", type: "password" },
        // Add userData to credentials (will not be displayed in form)
        userData: { label: "User Data", type: "text", value: "" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null
        }

        try {
          // Cast credentials to ExtendedCredentials for TypeScript to know about userData
          const extendedCredentials = credentials as ExtendedCredentials

          // If userData is provided, use it directly
          if (extendedCredentials.userData) {
            try {
              const userData = JSON.parse(extendedCredentials.userData)

              // Check if user has Admin role in roles array
              if (!userData.roles || !userData.roles.includes("Admin")) {
                console.error("Access denied: User is not an admin. Roles:", userData.roles)
                return null
              }

              // Return the user data
              return userData
            } catch (error) {
              console.error("Error parsing userData:", error)
              return null
            }
          }

          // Get API URL from environment variable
          const apiUrl = process.env.NEXT_PUBLIC_API_URL

          // Log for debugging
          console.log("Using API URL:", apiUrl)

          if (!apiUrl) {
            console.error("NEXT_PUBLIC_API_URL is not defined")
            return null
          }

          // Call login API with URL from environment variable
          const response = await fetch(`${apiUrl}/gateway/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              email: extendedCredentials.email,
              password: extendedCredentials.password,
            }),
          })

          console.log("Login API response status:", response.status)

          if (!response.ok) {
            const errorText = await response.text()
            console.error("Login API error:", errorText)
            return null
          }

          const user = await response.json()

          // Check if user has Admin role in roles array
          if (!user.roles || !user.roles.includes("Admin")) {
            console.error("Access denied: User is not an admin. Roles:", user.roles)
            return null
          }

          return user
        } catch (error) {
          console.error("Auth error:", error)
          return null
        }
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id
        token.token = user.token
        token.username = user.username
        token.roles = user.roles || []
        token.photoUrl = user.photoUrl
        token.isOnline = user.isOnline
        token.verified = user.verified
      }
      return token
    },
    async session({ session, token }) {
      session.token = token.token
      session.user.id = token.id
      session.user.username = token.username
      session.user.roles = token.roles || []
      session.user.photoUrl = token.photoUrl
      session.user.isOnline = token.isOnline
      session.user.verified = token.verified

      return session
    },
  },
  pages: {
    signIn: "/login",
  },
  session: {
    strategy: "jwt",
    maxAge: 30 * 24 * 60 * 60, // 30 days
  },
  debug: process.env.NODE_ENV === "development",
  secret: process.env.NEXTAUTH_SECRET,
}

const handler = NextAuth(authOptions)
export { handler as GET, handler as POST }
