import { fetchWithAuth } from "./api"

// Query parameters for date-based endpoints
export interface DateRangeParams {
  startDate?: string // Format: YYYY-MM-DD
  endDate?: string
}

// Dashboard summary interface
export interface DashboardSummary {
  totalRevenue: number
  totalPlayers: number
  totalManagers: number
  newPlayers: number
  newManagers: number
  totalOrders: number
}

// Monthly user stats interface
export interface MonthlyUserStats {
  month: number
  players: number
  managers: number
}

// Monthly revenue stats interface
export interface MonthlyRevenueStats {
  month: number
  revenue: number
}

// Facility revenue interface
export interface FacilityRevenue {
  facilityId: string
  facilityName: string
  revenue: number
}

// Province revenue interface
export interface ProvinceRevenue {
  province: string
  revenue: number
}

// Hourly revenue interface
export interface HourlyRevenueStats {
  hourRange: string
  revenue: number
}

// Update the endpoint URLs to match your port configuration
export const statisticService = {
  // Revenue endpoints - using ordersApiEndpoint (port 4000)
  getTotalRevenue: (params?: DateRangeParams): Promise<number> => {
    const searchParams = new URLSearchParams()
    if (params?.startDate) searchParams.append("startDate", params.startDate)
    if (params?.endDate) searchParams.append("endDate", params.endDate)

    const queryString = searchParams.toString()
    const endpoint = queryString
      ? `http://localhost:4000/api/admin-dashboard/total-revenue?${queryString}`
      : "http://localhost:4000/api/admin-dashboard/total-revenue"

    return fetchWithAuth<number>(endpoint)
  },

  // User count endpoints - using usersApiEndpoint (port 1000)
  getTotalPlayers: (params?: DateRangeParams): Promise<number> => {
    const searchParams = new URLSearchParams()
    if (params?.startDate) searchParams.append("startDate", params.startDate)
    if (params?.endDate) searchParams.append("endDate", params.endDate)

    const queryString = searchParams.toString()
    const endpoint = queryString
      ? `http://localhost:1000/api/admin-dashboard/total-players?${queryString}`
      : "http://localhost:1000/api/admin-dashboard/total-players"

    return fetchWithAuth<number>(endpoint)
  },

  getTotalManagers: (params?: DateRangeParams): Promise<number> => {
    const searchParams = new URLSearchParams()
    if (params?.startDate) searchParams.append("startDate", params.startDate)
    if (params?.endDate) searchParams.append("endDate", params.endDate)

    const queryString = searchParams.toString()
    const endpoint = queryString
      ? `http://localhost:1000/api/admin-dashboard/total-managers?${queryString}`
      : "http://localhost:1000/api/admin-dashboard/total-managers"

    return fetchWithAuth<number>(endpoint)
  },

  getTotalOrders: (params?: DateRangeParams): Promise<number> => {
    const searchParams = new URLSearchParams()
    if (params?.startDate) searchParams.append("startDate", params.startDate)
    if (params?.endDate) searchParams.append("endDate", params.endDate)

    const queryString = searchParams.toString()
    const endpoint = queryString
      ? `http://localhost:4000/api/admin-dashboard/total-orders?${queryString}`
      : "http://localhost:4000/api/admin-dashboard/total-orders"

    return fetchWithAuth<number>(endpoint)
  },

  // Add new dashboard summary endpoint
  getDashboardSummary: (): Promise<DashboardSummary> => {
    return fetchWithAuth<DashboardSummary>(`http://localhost:5000/gateway/admin-dashboard/summary`)
  },

  // Keep the helper methods unchanged
  getCurrentMonthStats: () => {
    const now = new Date()
    const startDate = new Date(now.getFullYear(), now.getMonth(), 1).toISOString().split("T")[0]
    const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0).toISOString().split("T")[0]

    return statisticService.getDateRangeStats(startDate, endDate)
  },

  getDateRangeStats: (startDate: string, endDate: string) => {
    const params = { startDate, endDate }
    return Promise.all([
      statisticService.getTotalRevenue(params),
      statisticService.getTotalPlayers(params),
      statisticService.getTotalManagers(params),
      statisticService.getTotalOrders(params),
    ])
  },

  getCurrentTotals: () => {
    return Promise.all([
      statisticService.getTotalRevenue(),
      statisticService.getTotalPlayers(),
      statisticService.getTotalManagers(),
      statisticService.getTotalOrders(),
    ])
  },

  // Add this new endpoint to the statisticService object
  getUserStats: (params: { year: number }): Promise<MonthlyUserStats[]> => {
    return fetchWithAuth<MonthlyUserStats[]>(
      `http://localhost:5000/gateway/admin-dashboard/user-stats?year=${params.year}`,
    )
  },

  // Add this method to the statisticService object
  getRevenueStats: (params: { year: number }): Promise<MonthlyRevenueStats[]> => {
    return fetchWithAuth<MonthlyRevenueStats[]>(
      `http://localhost:5000/gateway/admin-dashboard/revenue-stats?year=${params.year}`,
    )
  },

  // Add this method to get facility revenue data
  getFacilityRevenue: (): Promise<FacilityRevenue[]> => {
    return fetchWithAuth<FacilityRevenue[]>(`http://localhost:5000/gateway/admin-dashboard/facility-revenue`)
  },

  // Add this method to get province revenue data
  getProvinceRevenue: (): Promise<ProvinceRevenue[]> => {
    return fetchWithAuth<ProvinceRevenue[]>(`http://localhost:5000/gateway/admin-dashboard/province-revenue`)
  },

  // Add this method to get hourly revenue data
  getRevenueByHour: (params?: { year?: number }): Promise<HourlyRevenueStats[]> => {
    const searchParams = new URLSearchParams()
    if (params?.year) searchParams.append("year", params.year.toString())

    const queryString = searchParams.toString()
    const endpoint = queryString
      ? `http://localhost:5000/gateway/admin-dashboard/revenue-by-hour?${queryString}`
      : "http://localhost:5000/gateway/admin-dashboard/revenue-by-hour"

    return fetchWithAuth<HourlyRevenueStats[]>(endpoint)
  },
}
