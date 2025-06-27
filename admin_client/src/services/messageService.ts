import { fetchWithAuth } from "./api"
import type { SignalRMessage, SignalRMessageThread } from "@/lib/types"

// Types for message service
export interface SendMessageParams {
  recipientId: string
  content: string
  resources?: File[]
}

export interface GetMessagesParams {
  otherUserId: string
  pageSize?: number
  pageNumber?: number
}

export const messageService = {
  // Gửi tin nhắn mới
  sendMessage: async (messageData: SendMessageParams) => {
    // Tạo FormData để gửi cả dữ liệu và file
    const formData = new FormData()
    formData.append("recipientId", messageData.recipientId)
    formData.append("content", messageData.content)

    // Thêm resources nếu có
    if (messageData.resources && messageData.resources.length > 0) {
      messageData.resources.forEach((file) => {
        formData.append(`resources`, file)
      })
    }

    return fetchWithAuth<SignalRMessage>("/gateway/messages", {
      method: "POST",
      body: formData,
    })
  },

  // Lấy tin nhắn với pagination (cho infinity scroll)
  getMessages: async (params: GetMessagesParams) => {
    const { otherUserId, pageSize = 20, pageNumber = 1 } = params
    const queryParams = new URLSearchParams({
      OtherUserId: otherUserId,
      pageSize: pageSize.toString(),
      pageNumber: pageNumber.toString(),
    })

    return fetchWithAuth<SignalRMessageThread>(`/gateway/messages?${queryParams}`)
  },
}
