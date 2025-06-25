import { fetchWithAuth } from "./api"
import type { SignalRGroupList } from "@/lib/types"

// Types for group service
export interface GetGroupsParams {
  pageSize?: number
  pageNumber?: number
}

export const groupService = {
  // Lấy danh sách groups với pagination (cho infinity scroll)
  getGroups: async (params: GetGroupsParams = {}) => {
    const { pageSize = 20, pageNumber = 1 } = params
    const queryParams = new URLSearchParams({
      pageSize: pageSize.toString(),
      pageNumber: pageNumber.toString(),
    })

    return fetchWithAuth<SignalRGroupList>(`/gateway/groups?${queryParams}`)
  },
}
