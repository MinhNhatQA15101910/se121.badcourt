"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { statisticService, type ProvinceRevenue } from "@/services/statisticService"

export function RevenueByRegion() {
  const [provinces, setProvinces] = useState<ProvinceRevenue[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    loadProvinceData()
  }, [])

  const loadProvinceData = async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await statisticService.getProvinceRevenue()
      // Sort by revenue in descending order
      const sortedData = data.sort((a, b) => b.revenue - a.revenue)
      setProvinces(sortedData)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load province data")
      console.error("Error loading province data:", err)
    } finally {
      setLoading(false)
    }
  }

  // Transform province data with calculated percentages and progress
  const transformProvinceData = (provinces: ProvinceRevenue[]) => {
    if (provinces.length === 0) return []

    const totalRevenue = provinces.reduce((sum, p) => sum + p.revenue, 0)

    return provinces.map((province, index) => ({
      ...province,
      rank: index + 1,
      percentage: totalRevenue > 0 ? Math.round((province.revenue / totalRevenue) * 100) : 0,
    }))
  }

  const provinceData = transformProvinceData(provinces)

  // Color palette for different provinces
  const colors = [
    "#4079ed", // Blue
    "#23c16b", // Green
    "#bf83ff", // Purple
    "#ff8900", // Orange
    "#fa5a7d", // Pink
    "#00bcd4", // Cyan
    "#ff5722", // Deep Orange
    "#9c27b0", // Purple
    "#607d8b", // Blue Grey
    "#795548", // Brown
    "#8bc34a", // Light Green
    "#ffc107", // Amber
  ]


  if (loading) {
    return (
      <Card className="shadow-sm h-full">
        <CardHeader className="pb-2">
          <CardTitle className="text-[#425166]">Revenue by Region</CardTitle>
        </CardHeader>
        <CardContent className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="text-[#737791]">Loading province data...</div>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (error) {
    return (
      <Card className="shadow-sm h-full">
        <CardHeader className="pb-2">
          <CardTitle className="text-[#425166]">Revenue by Region</CardTitle>
        </CardHeader>
        <CardContent className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="text-red-500 mb-2">Error loading data</div>
            <button onClick={loadProvinceData} className="text-sm text-blue-500 hover:underline">
              Try again
            </button>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (provinceData.length === 0) {
    return (
      <Card className="shadow-sm h-full">
        <CardHeader className="pb-2">
          <CardTitle className="text-[#425166]">Revenue by Region</CardTitle>
        </CardHeader>
        <CardContent className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="text-[#737791]">No province data available</div>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="shadow-sm h-full">
      <CardHeader className="pb-2">
        <CardTitle className="text-[#425166]">Revenue by Region</CardTitle>
      </CardHeader>
      <CardContent className="p-0">
        <div className="max-h-[350px] overflow-y-auto px-6 pb-6">
          <table className="w-full table-fixed">
            <thead className="sticky top-0 bg-white z-10">
              <tr className="text-[#737791] text-sm border-b border-gray-200">
                <th className="font-medium text-left pb-3 pt-2 w-12">#</th>
                <th className="font-medium text-left pb-3 pt-2">Region</th>
                <th className="font-medium text-left pb-3 pt-2 w-24">Revenue</th>
                <th className="font-medium text-left pb-3 pt-2 w-32">Share</th>
              </tr>
            </thead>
            <tbody>
              {provinceData.map((province, index) => (
                <RegionRow
                  key={`${province.province}-${index}`}
                  id={province.rank.toString().padStart(2, "0")}
                  region={province.province}
                  revenue={province.revenue}
                  progress={province.percentage}
                  color={colors[index % colors.length]}
                  percentage={`${province.percentage}%`}
                />
              ))}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  )
}

interface RegionRowProps {
  id: string
  region: string
  revenue: number
  progress: number
  color: string
  percentage: string
}

function RegionRow({ id, region, revenue, progress, color, percentage }: RegionRowProps) {
  const formatRevenue = (amount: number) => {
    if (amount >= 1000000) {
      return `${(amount / 1000000).toFixed(1)}M đ`
    } else if (amount >= 1000) {
      return `${(amount / 1000).toFixed(0)}k đ`
    }
    return `${amount.toLocaleString()} đ`
  }

  const formatRevenueShort = (amount: number) => {
    if (amount >= 1000000) {
      return `${(amount / 1000000).toFixed(1)}M`
    } else if (amount >= 1000) {
      return `${(amount / 1000).toFixed(0)}k`
    }
    return amount.toLocaleString()
  }

  return (
    <tr
      className="border-b border-gray-100 last:border-0 transition-all hover:bg-gray-50 group cursor-pointer"
      title={`${region} - Revenue: ${formatRevenue(revenue)} (${percentage} of total)`}
    >
      <td className="py-4 text-[#425166] w-12">{id}</td>
      <td className="py-4 text-[#425166] pr-4">
        <div className="font-medium group-hover:text-[#4079ed] transition-colors truncate" title={region}>
          {region}
        </div>
      </td>
      <td className="py-4 text-[#425166] w-24">
        <span className="text-sm font-medium">{formatRevenueShort(revenue)}</span>
      </td>
      <td className="py-4 w-32">
        <div className="flex items-center gap-2">
          <Progress value={progress} className="h-2 flex-1" indicatorColor={color} />
          <span
            className="inline-block px-2 py-1 rounded-full text-xs font-medium whitespace-nowrap transition-all group-hover:scale-105"
            style={{ backgroundColor: `${color}20`, color: color }}
          >
            {percentage}
          </span>
        </div>
      </td>
    </tr>
  )
}
