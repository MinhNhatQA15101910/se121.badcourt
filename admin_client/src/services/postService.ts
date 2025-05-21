import { fetchWithAuth } from "./api"
import type { Post, CreatePostParams } from "@/lib/types"

export const postService = {
  // 1. Lấy danh sách bài đăng
  getPosts: () => fetchWithAuth<Post[]>("/gateway/posts"),

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
}
