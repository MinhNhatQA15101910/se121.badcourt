import { fetchWithAuth } from "./api"

import type { SignalRGroupList } from "@/lib/types"

// Types for group service
export interface GetGroupsParams {
  pageSize?: number
  pageNumber?: number
  search?: string // New search parameter
}

export const groupService = {
  // Lấy danh sách groups với pagination và search (cho infinity scroll)
  getGroups: async (params: GetGroupsParams = {}) => {
    const { pageSize = 20, pageNumber = 1, search: search } = params

    const queryParams = new URLSearchParams({
      pageSize: pageSize.toString(),
      pageNumber: pageNumber.toString(),
    })

    // Add search parameter if provided
    if (search && search.trim()) {
      queryParams.append("username", search.trim())
    }

    return fetchWithAuth<SignalRGroupList>(`/gateway/groups?${queryParams}`)
  },
}
