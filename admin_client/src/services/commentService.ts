import { fetchWithAuth } from "./api"
import type { Comment, CreateCommentParams } from "@/lib/types"

export const commentService = {
  // 1. Lấy danh sách bình luận của một bài đăng
  getComments: (postId: string) => fetchWithAuth<Comment[]>(`/gateway/comments?postId=${postId}`),

  // 2. Tạo bình luận mới
  createComment: async (commentData: CreateCommentParams) => {
    // Tạo FormData để gửi cả dữ liệu và file
    const formData = new FormData()
    formData.append("postId", commentData.postId)
    formData.append("content", commentData.content)

    // Thêm resources nếu có
    if (commentData.resources && commentData.resources.length > 0) {
      commentData.resources.forEach((file) => {
        formData.append(`resources`, file)
      })
    }

    return fetchWithAuth<Comment>("/gateway/comments", {
      method: "POST",
      body: formData,
    })
  },

  // 3. Thích/bỏ thích bình luận
  toggleLikeComment: (commentId: string) =>
    fetchWithAuth<{ success: boolean }>(`/gateway/comments/toggle-like/${commentId}`, {
      method: "POST",
    }),

  // 4. Xóa bình luận
  deleteComment: (commentId: string) =>
    fetchWithAuth<void>(`/gateway/comments/${commentId}`, {
      method: "DELETE",
    }),

  // 5. Cập nhật bình luận
  updateComment: (commentId: string, content: string, resources?: File[]) => {
    const formData = new FormData()
    formData.append("content", content)

    // Thêm resources nếu có
    if (resources && resources.length > 0) {
      resources.forEach((file) => {
        formData.append(`resources`, file)
      })
    }

    return fetchWithAuth<Comment>(`/gateway/comments/${commentId}`, {
      method: "PUT",
      body: formData,
    })
  },
}
