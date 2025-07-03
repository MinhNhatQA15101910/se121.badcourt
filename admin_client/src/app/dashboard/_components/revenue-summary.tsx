"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { PieChart, FileText, Users, Download } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { statisticService, type DashboardSummary } from "@/services/statisticService"

export function RevenueSummary() {
  const [summaryData, setSummaryData] = useState<DashboardSummary | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Load initial summary data
  useEffect(() => {
    loadSummaryData()
  }, [])

  const loadSummaryData = async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await statisticService.getDashboardSummary()
      setSummaryData(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load summary data")
      console.error("Error loading summary data:", err)
    } finally {
      setLoading(false)
    }
  }

  const handleExport = () => {
    const exportData = {
      data: summaryData,
      exportedAt: new Date().toISOString(),
    }

    const dataStr = JSON.stringify(exportData, null, 2)
    const dataBlob = new Blob([dataStr], { type: "application/json" })
    const url = URL.createObjectURL(dataBlob)
    const link = document.createElement("a")
    link.href = url
    link.download = `revenue-summary-${new Date().toISOString().split("T")[0]}.json`
    link.click()
    URL.revokeObjectURL(url)
  }

  const formatCurrency = (amount: number) => {
    if (amount >= 1000000) {
      return `${(amount / 1000000).toFixed(1)}M đ`
    } else if (amount >= 1000) {
      return `${(amount / 1000).toFixed(0)}k đ`
    }
    return `${amount.toLocaleString()} đ`
  }

  const currentData = {
    revenue: summaryData?.totalRevenue || 0,
    players: summaryData?.totalPlayers || 0,
    managers: summaryData?.totalManagers || 0,
    orders: summaryData?.totalOrders || 0,
  }

  const getChangeText = () => {
    return summaryData
      ? `+${summaryData.newPlayers} new players, +${summaryData.newManagers} new managers`
      : "Overall statistics"
  }

  return (
    <Card className="shadow-sm h-full">
      <CardHeader className="pb-2 flex flex-row items-center justify-between">
        <div>
          <CardTitle className="text-[#425166]">Revenue Summary</CardTitle>
          <CardDescription>Overall platform statistics</CardDescription>
        </div>
        <Button variant="outline" size="sm" className="h-8 bg-transparent" onClick={handleExport}>
          <Download size={14} className="mr-2" />
          Export
        </Button>
      </CardHeader>
      <CardContent>
        {/* Error State */}
        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-md">
            <div className="text-red-600 text-sm">{error}</div>
            <button onClick={loadSummaryData} className="text-red-600 text-sm underline mt-1">
              Try again
            </button>
          </div>
        )}

        {/* Stats Section - Horizontal Layout */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard
            icon={<PieChart size={20} />}
            iconBg="bg-[#fa5a7d]"
            iconBgLight="bg-[#ffe2e5]"
            value={formatCurrency(currentData.revenue)}
            label="Total Revenue"
            change={getChangeText()}
            loading={loading}
          />
          <StatCard
            icon={<FileText size={20} />}
            iconBg="bg-[#ff8900]"
            iconBgLight="bg-[#fff4de]"
            value={currentData.orders.toLocaleString()}
            label="Total Orders"
            change={getChangeText()}
            loading={loading}
          />
          <StatCard
            icon={<Users size={20} />}
            iconBg="bg-[#23c16b]"
            iconBgLight="bg-[#dcfce7]"
            value={currentData.managers.toLocaleString()}
            label="Total Managers"
            change={getChangeText()}
            loading={loading}
          />
          <StatCard
            icon={<Users size={20} />}
            iconBg="bg-[#bf83ff]"
            iconBgLight="bg-[#f3e8ff]"
            value={currentData.players.toLocaleString()}
            label="Total Players"
            change={getChangeText()}
            loading={loading}
          />
        </div>

        {/* Summary Info */}
        {summaryData && (
          <div className="mt-4 p-3 bg-blue-50 border border-blue-200 rounded-md">
            <div className="text-sm text-blue-800">
              <strong>Recent Activity:</strong> {summaryData.newPlayers} new players and {summaryData.newManagers} new
              managers joined recently
            </div>
          </div>
        )}
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
      <div className="text-xs mt-1 text-[#737791]">{change}</div>
    </div>
  )
}
