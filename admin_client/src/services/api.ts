import { getSession } from "next-auth/react"

const API_URL = process.env.NEXT_PUBLIC_API_URL

// Đảm bảo export fetchWithAuth thay vì fetchApi
export async function fetchWithAuth<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const session = await getSession()

  if (!session?.token) {
    throw new Error("No token available")
  }

  const defaultHeaders = {
    "Content-Type": "application/json",
    Authorization: `Bearer ${session.token}`,
  }

  const response = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers: {
      ...defaultHeaders,
      ...options.headers,
    },
  })

  if (!response.ok) {
    const error = await response.text()
    throw new Error(`API error: ${response.status} - ${error}`)
  }

  return response.json()
}