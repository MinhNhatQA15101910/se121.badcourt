import { fetchWithAuth, fetchWithPagination } from "./api"
import type { Facility } from "@/lib/types"

// Simplified query params to match your API
export interface FacilityQueryParams {
  state?: "pending" | "approved" | "rejected"
  orderBy?: "location" | "price" | "registeredAt"
  sortBy?: "asc" | "desc"
  province?: string
  search?: string
  pageSize?: number
  pageNumber?: number
}

export interface UpdateFacilityParams {
  facilityName?: string
  description?: string
  facebookUrl?: string
  policy?: string
  courtsAmount?: number
  minPrice?: number
  maxPrice?: number
  detailAddress?: string
  province?: string
  photos?: File[]
}

export interface RegisterFacilityParams {
  facilityName: string
  description: string
  facebookUrl?: string
  policy: string
  courtsAmount: number
  minPrice: number
  maxPrice: number
  detailAddress: string
  province: string
  location: {
    type: "Point"
    coordinates: [number, number] // [longitude, latitude]
  }
  photos: File[]
  managerInfo: {
    fullName: string
    email: string
    phoneNumber: string
    citizenId: string
    citizenImageFront: File
    citizenImageBack: File
    bankCardFront: File
    bankCardBack: File
    businessLicenseImages: File[]
  }
}

export const facilityService = {
  // Get facilities with filtering and pagination
  getFacilities: async (params?: FacilityQueryParams) => {
    const searchParams = new URLSearchParams()

    if (params?.state) {
      searchParams.append("state", params.state)
    }
    if (params?.orderBy) {
      searchParams.append("orderBy", params.orderBy)
    }
    if (params?.sortBy) {
      searchParams.append("sortBy", params.sortBy)
    }
    if (params?.province) {
      searchParams.append("province", params.province)
    }
    if (params?.search) {
      searchParams.append("search", params.search)
    }
    if (params?.pageSize) {
      searchParams.append("pageSize", params.pageSize.toString())
    }
    if (params?.pageNumber) {
      searchParams.append("pageNumber", params.pageNumber.toString())
    }

    const queryString = searchParams.toString()
    const endpoint = queryString ? `/gateway/facilities?${queryString}` : "/gateway/facilities"

    console.log("Fetching facilities from:", endpoint)

    // Use custom fetch function that handles pagination headers
    return fetchWithPagination<Facility>(endpoint)
  },

  // Get facility by ID
  getFacilityById: (facilityId: string): Promise<Facility> =>
    fetchWithAuth<Facility>(`/gateway/facilities/${facilityId}`),

  // Get all provinces - returns array of strings
  getProvinces: (): Promise<string[]> => fetchWithAuth<string[]>("/gateway/facilities/provinces"),

  // Register new facility
  registerFacility: async (facilityData: RegisterFacilityParams) => {
    const formData = new FormData()

    // Basic facility info
    formData.append("facilityName", facilityData.facilityName)
    formData.append("description", facilityData.description)
    formData.append("policy", facilityData.policy)
    formData.append("courtsAmount", facilityData.courtsAmount.toString())
    formData.append("minPrice", facilityData.minPrice.toString())
    formData.append("maxPrice", facilityData.maxPrice.toString())
    formData.append("detailAddress", facilityData.detailAddress)
    formData.append("province", facilityData.province)

    if (facilityData.facebookUrl) {
      formData.append("facebookUrl", facilityData.facebookUrl)
    }

    // Location data
    formData.append("location", JSON.stringify(facilityData.location))

    // Facility photos
    facilityData.photos.forEach((photo) => {
      formData.append(`photos`, photo)
    })

    // Manager info
    const managerInfo = facilityData.managerInfo
    formData.append("managerInfo.fullName", managerInfo.fullName)
    formData.append("managerInfo.email", managerInfo.email)
    formData.append("managerInfo.phoneNumber", managerInfo.phoneNumber)
    formData.append("managerInfo.citizenId", managerInfo.citizenId)
    formData.append("managerInfo.citizenImageFront", managerInfo.citizenImageFront)
    formData.append("managerInfo.citizenImageBack", managerInfo.citizenImageBack)
    formData.append("managerInfo.bankCardFront", managerInfo.bankCardFront)
    formData.append("managerInfo.bankCardBack", managerInfo.bankCardBack)

    managerInfo.businessLicenseImages.forEach((image) => {
      formData.append("managerInfo.businessLicenseImages", image)
    })

    return fetchWithAuth<Facility>("/gateway/facilities", {
      method: "POST",
      body: formData,
    })
  },

  // Update facility
  updateFacility: (facilityId: string, updateData: UpdateFacilityParams) => {
    const formData = new FormData()

    // Add only the fields that are being updated
    Object.entries(updateData).forEach(([key, value]) => {
      if (value !== undefined && key !== "photos") {
        formData.append(key, value.toString())
      }
    })

    // Handle photos separately
    if (updateData.photos && updateData.photos.length > 0) {
      updateData.photos.forEach((photo) => {
        formData.append("photos", photo)
      })
    }

    return fetchWithAuth<Facility>(`/gateway/facilities/${facilityId}`, {
      method: "PUT",
      body: formData,
    })
  },

  // Approve facility
  approveFacility: (facilityId: string) =>
    fetchWithAuth<{ success: boolean }>(`/gateway/facilities/approve/${facilityId}`, {
      method: "PATCH",
    }),

  // Reject facility
  rejectFacility: (facilityId: string, reason?: string) => {
    const body = reason ? { reason } : undefined

    return fetchWithAuth<{ success: boolean }>(`/gateway/facilities/reject/${facilityId}`, {
      method: "PATCH",
      body: body ? JSON.stringify(body) : undefined,
    })
  },

  // Delete facility
  deleteFacility: (facilityId: string) =>
    fetchWithAuth<void>(`/gateway/facilities/${facilityId}`, {
      method: "DELETE",
    }),

  // Update facility active status
  updateActiveStatus: (facilityId: string, isActive: boolean) =>
    fetchWithAuth<{ success: boolean }>(`/gateway/facilities/${facilityId}/active`, {
      method: "PUT",
      body: JSON.stringify({ isActive }),
    }),

  // Get facilities by province (helper method)
  getFacilitiesByProvince: (province: string, params?: Omit<FacilityQueryParams, "province">) =>
    facilityService.getFacilities({ ...params, province }),

  // Search facilities (helper method)
  searchFacilities: (searchTerm: string, params?: Omit<FacilityQueryParams, "search">) =>
    facilityService.getFacilities({ ...params, search: searchTerm }),

  // Get pending facilities (helper method)
  getPendingFacilities: (params?: Omit<FacilityQueryParams, "state">) =>
    facilityService.getFacilities({ ...params, state: "pending" }),

  // Get approved facilities (helper method)
  getApprovedFacilities: (params?: Omit<FacilityQueryParams, "state">) =>
    facilityService.getFacilities({ ...params, state: "approved" }),

  // Get rejected facilities (helper method)
  getRejectedFacilities: (params?: Omit<FacilityQueryParams, "state">) =>
    facilityService.getFacilities({ ...params, state: "rejected" }),
}
