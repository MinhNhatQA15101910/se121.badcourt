import { fetchWithAuth } from "./api"
import type { Court } from "@/lib/types"

export interface CourtQueryParams {
  facilityId?: string
  state?: string
  pageSize?: number
  pageNumber?: number
}

export const courtService = {
  // Get courts by facility ID
  getCourtsByFacilityId: async (facilityId: string): Promise<Court[]> => {
    console.log("Fetching courts for facility:", facilityId)
    return fetchWithAuth<Court[]>(`/gateway/courts?facilityId=${facilityId}`)
  },

  // Get all courts with filtering
  getCourts: async (params?: CourtQueryParams): Promise<Court[]> => {
    const searchParams = new URLSearchParams()

    if (params?.facilityId) {
      searchParams.append("facilityId", params.facilityId)
    }
    if (params?.state) {
      searchParams.append("state", params.state)
    }
    if (params?.pageSize) {
      searchParams.append("pageSize", params.pageSize.toString())
    }
    if (params?.pageNumber) {
      searchParams.append("pageNumber", params.pageNumber.toString())
    }

    const queryString = searchParams.toString()
    const endpoint = queryString ? `/gateway/courts?${queryString}` : "/gateway/courts"

    console.log("Fetching courts from:", endpoint)
    return fetchWithAuth<Court[]>(endpoint)
  },

  // Get court by ID
  getCourtById: (courtId: string): Promise<Court> => fetchWithAuth<Court>(`/gateway/courts/${courtId}`),

  // Create new court
  createCourt: (courtData: Omit<Court, "id" | "createdAt">): Promise<Court> =>
    fetchWithAuth<Court>("/gateway/courts", {
      method: "POST",
      body: JSON.stringify(courtData),
    }),

  // Update court
  updateCourt: (courtId: string, courtData: Partial<Court>): Promise<Court> =>
    fetchWithAuth<Court>(`/gateway/courts/${courtId}`, {
      method: "PUT",
      body: JSON.stringify(courtData),
    }),

  // Delete court
  deleteCourt: (courtId: string): Promise<void> =>
    fetchWithAuth<void>(`/gateway/courts/${courtId}`, {
      method: "DELETE",
    }),
}
