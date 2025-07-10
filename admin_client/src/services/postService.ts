import { fetchWithAuth } from "./api"
import type { Post, CreatePostParams } from "@/lib/types"

export interface GetPostsParams {
  pageNumber?: number
  pageSize?: number
  sortBy?: "desc" | "asc"
  orderBy?: "createdAt" | "reportsCount" | "likesCount" | "commentsCount"
  search?: string
}

export interface PaginatedResponse<T> {
  items: T[]
  currentPage: number
  totalPages: number
  totalCount: number
  pageSize: number
}

export const postService = {
  // 1. Lấy danh sách bài đăng với query parameters
  getPosts: async (params?: GetPostsParams) => {
    const queryParams = new URLSearchParams()

    if (params?.pageNumber) queryParams.append("pageNumber", params.pageNumber.toString())
    if (params?.pageSize) queryParams.append("pageSize", params.pageSize.toString())
    if (params?.sortBy) queryParams.append("sortBy", params.sortBy)
    if (params?.orderBy) queryParams.append("orderBy", params.orderBy)
    if (params?.search) queryParams.append("search", params.search)

    // Mặc định sắp xếp theo createdAt nếu không có orderBy
    if (!params?.orderBy) {
      queryParams.append("orderBy", "createdAt")
      queryParams.append("sortBy", params?.sortBy || "desc")
    }

    const queryString = queryParams.toString()
    const url = queryString ? `/gateway/posts?${queryString}` : "/gateway/posts"

    try {
      const response = await fetchWithAuth<Post[]>(url)
      
      // If the API returns an array directly, wrap it in pagination structure
      if (Array.isArray(response)) {
        return {
          items: response,
          currentPage: params?.pageNumber || 1,
          totalPages: Math.ceil(response.length / (params?.pageSize || 10)),
          totalCount: response.length,
          pageSize: params?.pageSize || 10
        } as PaginatedResponse<Post>
      }
      
      // If it's already in the expected format, return as is
      return response as PaginatedResponse<Post>
    } catch (error) {
      console.error("Error fetching posts:", error)
      throw error
    }
  },

  // 2. Lấy bài đăng theo ID
  getPostById: (id: string) => fetchWithAuth<Post>(`/gateway/posts/${id}`),

  // 3. Tạo bài đăng mới
  createPost: async (postData: CreatePostParams) => {
    // Tạo FormData để gửi cả dữ liệu và file
    const formData = new FormData()
    formData.append("title", postData.title)
    formData.append("content", postData.content)
    formData.append("category", postData.category)

    // Thêm resources nếu có
    if (postData.resources && postData.resources.length > 0) {
      postData.resources.forEach((file) => {
        formData.append(`resources`, file)
      })
    }

    return fetchWithAuth<Post>("/gateway/posts", {
      method: "POST",
      body: formData,
    })
  },

  // 4. Thích/bỏ thích bài đăng
  toggleLikePost: (postId: string) =>
    fetchWithAuth<{ success: boolean }>(`/gateway/posts/toggle-like/${postId}`, {
      method: "POST",
    }),

  // 5. Xóa bài đăng
  deletePost: (postId: string) =>
    fetchWithAuth<void>(`/gateway/posts/${postId}`, {
      method: "DELETE",
    }),

  // 6. Cập nhật bài đăng
  updatePost: (postId: string, postData: Partial<CreatePostParams>) => {
    const formData = new FormData()

    if (postData.title) formData.append("title", postData.title)
    if (postData.content) formData.append("content", postData.content)
    if (postData.category) formData.append("category", postData.category)

    // Thêm resources nếu có
    if (postData.resources && postData.resources.length > 0) {
      postData.resources.forEach((file) => {
        formData.append(`resources`, file)
      })
    }

    return fetchWithAuth<Post>(`/gateway/posts/${postId}`, {
      method: "PUT",
      body: formData,
    })
  },

  // 7. Báo cáo bài đăng
  reportPost: (postId: string) =>
    fetchWithAuth<{ success: boolean }>(`/gateway/posts/report/${postId}`, {
      method: "POST",
    }),
}
