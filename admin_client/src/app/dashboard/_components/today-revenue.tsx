"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { PieChart, FileText, Users, Download } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { DatePicker } from "@/components/ui/date-picker"
import { statisticService } from "@/services/statisticService"

export function TodayRevenue() {
  const [startDate, setStartDate] = useState<Date | undefined>(new Date())
  const [endDate, setEndDate] = useState<Date | undefined>(new Date())
  const [stats, setStats] = useState({
    revenue: 0,
    players: 0,
    managers: 0,
    orders: 0,
  })
  const [previousStats, setPreviousStats] = useState({
    revenue: 0,
    players: 0,
    managers: 0,
    orders: 0,
  })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Load initial data for today
  useEffect(() => {
    loadTodayData()
  }, [])

  const loadTodayData = async () => {
    try {
      setLoading(true)
      setError(null)

      const today = new Date()
      const todayStr = today.toISOString().split("T")[0]

      // Get today's data
      const [revenue, players, managers, orders] = await statisticService.getDateRangeStats(todayStr, todayStr)
      setStats({ revenue, players, managers, orders })

      // Get yesterday's data for comparison
      const yesterday = new Date(today)
      yesterday.setDate(yesterday.getDate() - 1)
      const yesterdayStr = yesterday.toISOString().split("T")[0]

      const [prevRevenue, prevPlayers, prevManagers, prevOrders] = await statisticService.getDateRangeStats(
        yesterdayStr,
        yesterdayStr,
      )
      setPreviousStats({
        revenue: prevRevenue,
        players: prevPlayers,
        managers: prevManagers,
        orders: prevOrders,
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load today's data")
      console.error("Error loading today's data:", err)
    } finally {
      setLoading(false)
    }
  }

  const handleDateRangeFilter = async () => {
    if (!startDate || !endDate) return

    try {
      setLoading(true)
      setError(null)

      const startDateStr = startDate.toISOString().split("T")[0]
      const endDateStr = endDate.toISOString().split("T")[0]

      // Get data for selected range
      const [revenue, players, managers, orders] = await statisticService.getDateRangeStats(startDateStr, endDateStr)
      setStats({ revenue, players, managers, orders })

      // Calculate previous period for comparison
      const daysDiff = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1
      const prevEndDate = new Date(startDate)
      prevEndDate.setDate(prevEndDate.getDate() - 1)
      const prevStartDate = new Date(prevEndDate)
      prevStartDate.setDate(prevStartDate.getDate() - daysDiff + 1)

      const prevStartDateStr = prevStartDate.toISOString().split("T")[0]
      const prevEndDateStr = prevEndDate.toISOString().split("T")[0]

      const [prevRevenue, prevPlayers, prevManagers, prevOrders] = await statisticService.getDateRangeStats(
        prevStartDateStr,
        prevEndDateStr,
      )
      setPreviousStats({
        revenue: prevRevenue,
        players: prevPlayers,
        managers: prevManagers,
        orders: prevOrders,
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to filter by date range")
      console.error("Error filtering by date range:", err)
    } finally {
      setLoading(false)
    }
  }

  const handleExport = () => {
    const exportData = {
      dateRange: {
        start: startDate?.toISOString().split("T")[0],
        end: endDate?.toISOString().split("T")[0],
      },
      stats,
      previousStats,
      exportedAt: new Date().toISOString(),
    }

    const dataStr = JSON.stringify(exportData, null, 2)
    const dataBlob = new Blob([dataStr], { type: "application/json" })
    const url = URL.createObjectURL(dataBlob)
    const link = document.createElement("a")
    link.href = url
    link.download = `revenue-summary-${startDate?.toISOString().split("T")[0]}-to-${endDate?.toISOString().split("T")[0]}.json`
    link.click()
    URL.revokeObjectURL(url)
  }

  // Calculate percentage changes
  const calculateChange = (current: number, previous: number) => {
    if (previous === 0) return current > 0 ? "+100%" : "0%"
    const change = ((current - previous) / previous) * 100
    return `${change >= 0 ? "+" : ""}${change.toFixed(1)}%`
  }

  const formatCurrency = (amount: number) => {
    if (amount >= 1000000) {
      return `${(amount / 1000000).toFixed(1)}M đ`
    } else if (amount >= 1000) {
      return `${(amount / 1000).toFixed(0)}k đ`
    }
    return `${amount.toLocaleString()} đ`
  }

  const isToday =
    startDate &&
    endDate &&
    startDate.toDateString() === endDate.toDateString() &&
    startDate.toDateString() === new Date().toDateString()

  return (
    <Card className="shadow-sm h-full">
      <CardHeader className="pb-2 flex flex-row items-center justify-between">
        <div>
          <CardTitle className="text-[#425166]">{isToday ? "Today's Revenue" : "Revenue Summary"}</CardTitle>
          <CardDescription>{isToday ? "Today's booking summary" : "Booking summary by date range"}</CardDescription>
        </div>
        <Button variant="outline" size="sm" className="h-8 bg-transparent" onClick={handleExport} disabled={loading}>
          <Download size={14} className="mr-2" />
          Export
        </Button>
      </CardHeader>
      <CardContent>
        {/* Date Picker Section */}
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          <div className="flex-1">
            <label className="text-sm text-[#737791] mb-1 block">Start Date</label>
            <DatePicker date={startDate} setDate={setStartDate} />
          </div>
          <div className="flex-1">
            <label className="text-sm text-[#737791] mb-1 block">End Date</label>
            <DatePicker date={endDate} setDate={setEndDate} />
          </div>
          <div className="flex items-end">
            <Button onClick={handleDateRangeFilter} disabled={loading || !startDate || !endDate} className="h-10">
              {loading ? "Loading..." : "Apply Filter"}
            </Button>
          </div>
        </div>

        {/* Error State */}
        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-md">
            <div className="text-red-600 text-sm">{error}</div>
            <button
              onClick={isToday ? loadTodayData : handleDateRangeFilter}
              className="text-red-600 text-sm underline mt-1"
            >
              Try again
            </button>
          </div>
        )}

        {/* Stats Section */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <StatCard
            icon={<PieChart size={20} />}
            iconBg="bg-[#fa5a7d]"
            iconBgLight="bg-[#ffe2e5]"
            value={formatCurrency(stats.revenue)}
            label="Total Revenue"
            change={`${calculateChange(stats.revenue, previousStats.revenue)} from previous period`}
            loading={loading}
          />
          <StatCard
            icon={<FileText size={20} />}
            iconBg="bg-[#ff8900]"
            iconBgLight="bg-[#fff4de]"
            value={stats.orders.toLocaleString()}
            label="Total Bookings"
            change={`${calculateChange(stats.orders, previousStats.orders)} from previous period`}
            loading={loading}
          />
          <StatCard
            icon={<Users size={20} />}
            iconBg="bg-[#23c16b]"
            iconBgLight="bg-[#dcfce7]"
            value={stats.managers.toLocaleString()}
            label="New Facility Owners"
            change={`${calculateChange(stats.managers, previousStats.managers)} from previous period`}
            loading={loading}
          />
          <StatCard
            icon={<Users size={20} />}
            iconBg="bg-[#bf83ff]"
            iconBgLight="bg-[#f3e8ff]"
            value={stats.players.toLocaleString()}
            label="New Customers"
            change={`${calculateChange(stats.players, previousStats.players)} from previous period`}
            loading={loading}
          />
        </div>
      </CardContent>
    </Card>
  )
}

// Updated StatCard Component
interface StatCardProps {
  icon: React.ReactNode
  iconBg: string
  iconBgLight: string
  value: string
  label: string
  change: string
  loading?: boolean
}

export function StatCard({ icon, iconBg, iconBgLight, value, label, change, loading = false }: StatCardProps) {
  const isPositive = change.startsWith("+")

  if (loading) {
    return (
      <div className={`p-4 rounded-lg ${iconBgLight} animate-pulse`}>
        <div className="flex items-center gap-3 mb-2">
          <div className={`w-10 h-10 rounded-full ${iconBg} flex items-center justify-center text-white`}>{icon}</div>
        </div>
        <div className="h-6 bg-gray-200 rounded mb-2"></div>
        <div className="h-4 bg-gray-200 rounded mb-1"></div>
        <div className="h-3 bg-gray-200 rounded w-3/4"></div>
      </div>
    )
  }

  return (
    <div className={`p-4 rounded-lg ${iconBgLight} transform transition-all duration-300 hover:scale-105`}>
      <div className="flex items-center gap-3 mb-2">
        <div className={`w-10 h-10 rounded-full ${iconBg} flex items-center justify-center text-white`}>{icon}</div>
      </div>
      <div className="text-xl font-bold">{value}</div>
      <div className="text-sm text-[#425166]">{label}</div>
      <div className={`text-xs mt-1 ${isPositive ? "text-[#23c16b]" : "text-[#fa5a7d]"}`}>{change}</div>
    </div>
  )
}
