import { getSession } from "next-auth/react"

// Đảm bảo API_URL luôn có giá trị mặc định hợp lệ
const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000"

// Cờ để kiểm soát việc sử dụng mock data
let USE_MOCK_DATA = false

// Định nghĩa type cho options với FormData
type FetchOptions = Omit<RequestInit, "body"> & {
  body?: FormData | string | object | null
}

// Định nghĩa interface cho custom headers
interface CustomHeaders {
  "Content-Type"?: string
  Authorization: string
  [key: string]: string | undefined
}

export async function fetchWithAuth<T>(endpoint: string, options: FetchOptions = {}): Promise<T> {
  try {
    // Nếu đang sử dụng mock data, trả về mock data
    if (USE_MOCK_DATA) {
      console.log(`Using mock data for: ${endpoint}`)
      return getMockData<T>(endpoint)
    }

    const session = await getSession()

    if (!session?.token) {
      throw new Error("No token available")
    }

    // Kiểm tra xem body có phải là FormData không
    const isFormData = options.body instanceof FormData

    // Tạo headers mặc định với type cụ thể
    const defaultHeaders: CustomHeaders = {
      Authorization: `Bearer ${session.token}`,
    }

    // Chỉ thêm Content-Type nếu không phải FormData
    if (!isFormData && options.body && typeof options.body !== "string") {
      defaultHeaders["Content-Type"] = "application/json"
    }

    // Chuẩn bị body
    let finalBody = options.body
    if (!isFormData && typeof finalBody === "object" && finalBody !== null) {
      finalBody = JSON.stringify(finalBody)
    }

    // Merge headers với type cụ thể
    const headers: CustomHeaders = {
      ...defaultHeaders,
      ...(options.headers as Record<string, string>),
    }

    // Nếu là FormData, xóa Content-Type để trình duyệt tự thêm
    if (isFormData && headers["Content-Type"]) {
      delete headers["Content-Type"]
    }

    // Log thông tin request để debug
    console.log(`Fetching: ${API_URL}${endpoint}`)

    // Chuyển đổi CustomHeaders thành Record<string, string> bằng cách loại bỏ các giá trị undefined
    const cleanedHeaders: Record<string, string> = {}
    Object.entries(headers).forEach(([key, value]) => {
      if (value !== undefined) {
        cleanedHeaders[key] = value
      }
    })

    const response = await fetch(`${API_URL}${endpoint}`, {
      ...options,
      headers: cleanedHeaders, // Sử dụng headers đã được làm sạch
      body: finalBody as BodyInit | null,
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error(`API error (${response.status}):`, errorText)
      throw new Error(`API error: ${response.status} - ${errorText}`)
    }

    // Kiểm tra nếu response là rỗng
    const contentType = response.headers.get("content-type")
    if (contentType && contentType.includes("application/json")) {
      return response.json()
    } else {
      // Trả về một đối tượng rỗng nếu không có JSON
      return {} as T
    }
  } catch (error) {
    // Xử lý lỗi mạng hoặc lỗi khác
    console.error("Fetch error:", error)

    // Kiểm tra lỗi mạng
    if (error instanceof TypeError && error.message.includes("Failed to fetch")) {
      console.error("Network error. Please check your connection and API server status.")
      throw new Error(
        `Network error: Could not connect to ${API_URL}. Please check your connection and API server status.`,
      )
    }

    throw error
  }
}

// Hàm tiện ích để kiểm tra kết nối API
export async function checkApiConnection(): Promise<boolean> {
  try {
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 5000) // 5 second timeout

    // Thay đổi endpoint từ /health thành một endpoint có khả năng cao hơn là tồn tại
    // Ví dụ: /gateway/posts hoặc bất kỳ endpoint nào khác mà API server của bạn hỗ trợ
    const testEndpoint = "/gateway/posts"
    console.log(`Testing API connection with: ${API_URL}${testEndpoint}`)

    const response = await fetch(`${API_URL}${testEndpoint}`, {
      method: "GET",
      signal: controller.signal,
    })

    clearTimeout(timeoutId)
    return response.ok
  } catch (error) {
    console.error("API connection check failed:", error)
    return false
  }
}

// Hàm tiện ích để lấy thông tin API
export function getApiInfo() {
  return {
    apiUrl: API_URL,
    isConfigured: !!process.env.NEXT_PUBLIC_API_URL,
    useMockData: USE_MOCK_DATA,
  }
}

// Hàm để bật/tắt chế độ sử dụng mock data
export function setUseMockData(useMock: boolean): void {
  USE_MOCK_DATA = useMock
  console.log(`Mock data mode ${useMock ? "enabled" : "disabled"}`)
}

// Hàm để lấy mock data dựa trên endpoint
function getMockData<T>(endpoint: string): T {
  // Tạo mock data cho các endpoint khác nhau
  if (endpoint.includes("/gateway/posts")) {
    return [
      {
        id: "mock-post-1",
        publisherId: "mock-user-1",
        publisherUsername: "John Doe",
        publisherImageUrl: "/abstract-geometric-shapes.png",
        title: "Mock Post 1",
        content: "This is a mock post for testing when API is not available.",
        category: "Sharing",
        resources: [],
        likesCount: 5,
        commentsCount: 2,
        isLiked: false,
        createdAt: new Date().toISOString(),
      },
      {
        id: "mock-post-2",
        publisherId: "mock-user-2",
        publisherUsername: "Jane Smith",
        publisherImageUrl: "/abstract-geometric-shapes.png",
        title: "Mock Post 2",
        content: "Another mock post with some sample content for testing.",
        category: "Question",
        resources: [
          {
            id: "mock-resource-1",
            url: "/lush-forest-stream.png",
            isMain: true,
            fileType: "Image",
          },
        ],
        likesCount: 10,
        commentsCount: 3,
        isLiked: true,
        createdAt: new Date(Date.now() - 86400000).toISOString(), // 1 day ago
      },
    ] as unknown as T
  }

  if (endpoint.includes("/gateway/comments")) {
    return [
      {
        id: "mock-comment-1",
        publisherId: "mock-user-3",
        postId: endpoint.includes("?postId=") ? endpoint.split("?postId=")[1] : "mock-post-1",
        publisherUsername: "Alice Johnson",
        publisherImageUrl: "/abstract-geometric-shapes.png",
        content: "This is a mock comment for testing.",
        resources: [],
        likesCount: 2,
        isLiked: false,
        createdAt: new Date().toISOString(),
      },
      {
        id: "mock-comment-2",
        publisherId: "mock-user-4",
        postId: endpoint.includes("?postId=") ? endpoint.split("?postId=")[1] : "mock-post-1",
        publisherUsername: "Bob Williams",
        publisherImageUrl: "/abstract-geometric-shapes.png",
        content: "Another mock comment for testing purposes.",
        resources: [],
        likesCount: 1,
        isLiked: true,
        createdAt: new Date(Date.now() - 3600000).toISOString(), // 1 hour ago
      },
    ] as unknown as T
  }

  // Trả về một đối tượng rỗng nếu không có mock data cho endpoint
  console.warn(`No mock data available for endpoint: ${endpoint}`)
  return {} as T
}
