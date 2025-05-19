import { NextResponse } from "next/server"
import type { User } from "@/lib/types"

export async function POST(request: Request) {
  try {
    console.log("API login route called")

    // Get data from request body
    const body = await request.json()
    const { email, password } = body

    console.log("Login attempt for email:", email)

    if (!email || !password) {
      console.log("Missing email or password")
      return NextResponse.json({ error: "Email and password are required" }, { status: 400 })
    }

    // Get API URL from environment variable
    const apiUrl = process.env.NEXT_PUBLIC_API_URL
    console.log("Using API URL:", apiUrl)

    if (!apiUrl) {
      console.error("NEXT_PUBLIC_API_URL is not defined")
      return NextResponse.json({ error: "Server configuration is incorrect" }, { status: 500 })
    }

    try {
      // Call backend API with URL from environment variable
      const fullUrl = `${apiUrl}/gateway/auth/login`
      console.log("Calling backend API at:", fullUrl)

      const response = await fetch(fullUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
      })

      console.log("Backend API response status:", response.status)

      if (!response.ok) {
        const errorText = await response.text()
        console.log("Backend API error:", errorText)

        let errorMessage = "Login failed"
        try {
          const errorData = JSON.parse(errorText)
          errorMessage = errorData.message || errorData.error || errorMessage
        } catch {
          // If not JSON, use original text
          errorMessage = errorText || errorMessage
        }

        return NextResponse.json({ error: errorMessage }, { status: response.status })
      }

      // Get user data from response
      const userData: User = await response.json()
      console.log("Login successful for user:", userData.username || userData.email)

      // Check if user has Admin role in roles array
      if (!userData.roles || !userData.roles.includes("Admin")) {
        console.log("Access denied: User is not an admin. Roles:", userData.roles)
        return NextResponse.json({ error: "Access denied. Admin privileges required." }, { status: 403 })
      }

      // Return user info and token
      return NextResponse.json(userData)
    } catch (error) {
      console.error("Error calling backend API:", error)
      return NextResponse.json({ error: "Cannot connect to authentication server" }, { status: 500 })
    }
  } catch (error) {
    console.error("Login route error:", error)
    return NextResponse.json({ error: "An error occurred during login" }, { status: 500 })
  }
}
