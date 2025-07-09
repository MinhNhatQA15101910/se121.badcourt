import { fetchWithAuth, fetchWithPagination } from "./api"

// User interface based on your API response
export interface User {
  id: string
  username: string
  email: string
  token: string | null
  photoUrl: string | null
  lastOnlineAt: string
  photos: Array<{
    id: string
    url: string
    isMain: boolean
  }>
  roles: string[]
  state: "Active" | "Locked"
  createdAt: string
}

// Query params for user filtering
export interface UserQueryParams {
  role?: "manager" | "player"
  state?: "locked" | "active"
  search?: string
  pageSize?: number
  pageNumber?: number
}

export const userService = {
  // Get users with filtering and pagination
  getUsers: async (params?: UserQueryParams) => {
    const searchParams = new URLSearchParams()

    // Set default role to manager as specified
    searchParams.append("role", params?.role || "manager")

    if (params?.state) {
      searchParams.append("state", params.state)
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
    const endpoint = `/gateway/users?${queryString}`

    console.log("Fetching users from:", endpoint)

    // Use custom fetch function that handles pagination headers
    return fetchWithPagination<User>(endpoint)
  },

  // Get user by ID
  getUserById: (userId: string): Promise<User> => fetchWithAuth<User>(`/gateway/users/${userId}`),

  // Update user status
  updateUserStatus: (userId: string, state: "Active" | "Locked") =>
    fetchWithAuth<{ success: boolean }>(`/gateway/users/${userId}/status`, {
      method: "PUT",
      body: JSON.stringify({ state }),
    }),

  // Delete user
  deleteUser: (userId: string) =>
    fetchWithAuth<void>(`/gateway/users/${userId}`, {
      method: "DELETE",
    }),

  // Search users (helper method)
  searchUsers: (searchTerm: string, params?: Omit<UserQueryParams, "search">) =>
    userService.getUsers({ ...params, search: searchTerm }),

  // Get active users (helper method)
  getActiveUsers: (params?: Omit<UserQueryParams, "state">) => userService.getUsers({ ...params, state: "active" }),

  // Get locked users (helper method)
  getLockedUsers: (params?: Omit<UserQueryParams, "state">) => userService.getUsers({ ...params, state: "locked" }),
}
