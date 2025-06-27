import { getSession } from "next-auth/react"

// API configuration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000"

// Helper function to get auth token from NextAuth session
export async function getAuthToken(): Promise<string> {
  if (typeof window !== "undefined") {
    try {
      // Get token from NextAuth session
      const session = await getSession()
      
      console.log("🔑 NextAuth Session:", {
        hasSession: !!session,
        hasToken: !!(session?.token),
        tokenLength: session?.token?.length || 0,
        tokenPreview: session?.token ? `${session.token.substring(0, 20)}...` : "No token found",
        userInfo: session?.user ? {
          id: session.user.id,
          username: session.user.username,
          roles: session.user.roles,
        } : "No user info",
      })

      return session?.token || ""
    } catch (error) {
      console.error("❌ Error getting NextAuth session:", error)
      return ""
    }
  }
  return ""
}

// Synchronous version for backward compatibility (will be empty on first call)
export function getAuthTokenSync(): string {
  // This is a fallback - the async version should be used
  console.warn("⚠️ Using sync token getter - token may not be available")
  return ""
}

// Enhanced fetch function with auth and proper error handling
export async function fetchWithAuth<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const url = endpoint.startsWith("http") ? endpoint : `${API_BASE_URL}${endpoint}`

  // Get token from NextAuth session
  const token = await getAuthToken()

  const config: RequestInit = {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    },
  }

  // Remove Content-Type for FormData
  if (options.body instanceof FormData) {
    delete (config.headers as Record<string, string>)["Content-Type"]
  }

  console.log("🚀 API Request:", {
    url,
    method: config.method || "GET",
    headers: config.headers,
    hasToken: !!token,
    tokenPreview: token ? `${token.substring(0, 20)}...` : "No token",
  })

  try {
    const response = await fetch(url, config)

    console.log("📡 API Response:", {
      status: response.status,
      statusText: response.statusText,
      url: response.url,
      headers: Object.fromEntries(response.headers.entries()),
    })

    if (!response.ok) {
      let errorMessage = `HTTP ${response.status}: ${response.statusText}`
      let errorDetails = ""

      try {
        const errorText = await response.text()
        if (errorText) {
          errorDetails = errorText
          errorMessage += ` - ${errorText}`
        }
      } catch {
      }

      console.error("❌ API Error:", {
        status: response.status,
        statusText: response.statusText,
        url: response.url,
        errorMessage,
        errorDetails,
        hasToken: !!token,
        tokenPreview: token ? `${token.substring(0, 20)}...` : "No token",
      })

      // Special handling for 401 Unauthorized
      if (response.status === 401) {
        console.error("🔐 Unauthorized - Token may be invalid or expired")
        console.error("🔍 Debug info:", {
          tokenExists: !!token,
          tokenLength: token?.length || 0,
          tokenFormat: token?.includes(".") ? "JWT-like" : "Simple string",
          authHeader: config.headers ? (config.headers as never)["Authorization"] : "No auth header",
        })
      }

      throw new Error(errorMessage)
    }

    // Handle empty responses (204 No Content)
    if (response.status === 204) {
      return {} as T
    }

    const contentType = response.headers.get("content-type")
    if (contentType && contentType.includes("application/json")) {
      const data = await response.json()
      console.log("✅ API Success:", data)
      return data
    }

    const textData = await response.text()
    console.log("✅ API Success (text):", textData)
    return textData as unknown as T
  } catch (error) {
    console.error("💥 Fetch error:", {
      error,
      url,
      hasToken: !!token,
      tokenPreview: token ? `${token.substring(0, 20)}...` : "No token",
    })
    throw error
  }
}

// Custom fetch function that handles pagination headers
export async function fetchWithPagination<T>(
  endpoint: string,
  options: RequestInit = {},
): Promise<{
  items: T[]
  currentPage: number
  totalPages: number
  pageSize: number
  totalCount: number
}> {
  const url = endpoint.startsWith("http") ? endpoint : `${API_BASE_URL}${endpoint}`

  // Get token from NextAuth session
  const token = await getAuthToken()

  const config: RequestInit = {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    },
  }

  console.log("🚀 Paginated API Request:", {
    url,
    method: config.method || "GET",
    headers: config.headers,
    hasToken: !!token,
  })

  try {
    const response = await fetch(url, config)

    console.log("📡 Paginated API Response:", {
      status: response.status,
      statusText: response.statusText,
      headers: Object.fromEntries(response.headers.entries()),
    })

    if (!response.ok) {
      let errorMessage = `HTTP ${response.status}: ${response.statusText}`

      try {
        const errorText = await response.text()
        if (errorText) {
          errorMessage += ` - ${errorText}`
        }
      } catch{
        // Ignore error parsing error message
      }

      console.error("❌ Paginated API Error:", errorMessage)
      throw new Error(errorMessage)
    }

    // Get pagination from headers
    const paginationHeader = response.headers.get("Pagination") || response.headers.get("pagination")
    let paginationData = {
      currentPage: 1,
      totalPages: 1,
      pageSize: 10,
      totalCount: 0,
    }

    if (paginationHeader) {
      try {
        console.log("📄 Raw pagination header:", paginationHeader)
        const parsed = JSON.parse(paginationHeader)
        console.log("📊 Parsed pagination:", parsed)

        paginationData = {
          currentPage: parsed.currentPage || parsed.CurrentPage || 1,
          totalPages: parsed.totalPages || parsed.TotalPages || 1,
          pageSize: parsed.itemsPerPage || parsed.ItemsPerPage || parsed.pageSize || parsed.PageSize || 10,
          totalCount: parsed.totalItems || parsed.TotalItems || parsed.totalCount || parsed.TotalCount || 0,
        }
      } catch (error) {
        console.error("❌ Failed to parse pagination header:", error)
      }
    }

    // Get the actual data
    let items: T[] = []

    // Handle empty responses (204 No Content)
    if (response.status === 204) {
      items = []
    } else {
      const contentType = response.headers.get("content-type")
      if (contentType && contentType.includes("application/json")) {
        const data = await response.json()
        items = Array.isArray(data) ? data : []
        console.log("✅ Paginated data received:", {
          itemsCount: items.length,
          sampleItem: items[0] || null,
        })
      }
    }

    const result = {
      items,
      ...paginationData,
    }

    console.log("🎯 Final pagination result:", {
      currentPage: result.currentPage,
      totalPages: result.totalPages,
      pageSize: result.pageSize,
      totalCount: result.totalCount,
      itemsCount: result.items.length,
    })

    return result
  } catch (error) {
    console.error("💥 Fetch with pagination error:", error)
    throw error
  }
}

// Health check function
export async function checkApiHealth(): Promise<boolean> {
  try {
    const response = await fetch(`${API_BASE_URL}/health`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })
    return response.ok
  } catch (error) {
    console.error("❌ API Health check failed:", error)
    return false
  }
}

// Test connection function
export async function testConnection(): Promise<{
  success: boolean
  message: string
  baseUrl: string
}> {
  try {
    const isHealthy = await checkApiHealth()

    if (isHealthy) {
      return {
        success: true,
        message: "API connection successful",
        baseUrl: API_BASE_URL,
      }
    } else {
      return {
        success: false,
        message: "API server is not responding",
        baseUrl: API_BASE_URL,
      }
    }
  } catch (error) {
    return {
      success: false,
      message: `Connection failed: ${error instanceof Error ? error.message : "Unknown error"}`,
      baseUrl: API_BASE_URL,
    }
  }
}
