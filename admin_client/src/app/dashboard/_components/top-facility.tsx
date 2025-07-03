"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { statisticService, type FacilityRevenue } from "@/services/statisticService"

export function TopFacility() {
  const [facilities, setFacilities] = useState<FacilityRevenue[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    loadFacilityData()
  }, [])

  const loadFacilityData = async () => {
    try {
      setLoading(true)
      setError(null)
      const data = await statisticService.getFacilityRevenue()
      // Sort by revenue in descending order
      const sortedData = data.sort((a, b) => b.revenue - a.revenue)
      setFacilities(sortedData)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load facility data")
      console.error("Error loading facility data:", err)
    } finally {
      setLoading(false)
    }
  }

  // Calculate progress and percentage for each facility
  const transformFacilityData = (facilities: FacilityRevenue[]) => {
    if (facilities.length === 0) return []

    const maxRevenue = Math.max(...facilities.map((f) => f.revenue))
    const totalRevenue = facilities.reduce((sum, f) => sum + f.revenue, 0)

    return facilities.map((facility, index) => ({
      ...facility,
      rank: index + 1,
      progress: maxRevenue > 0 ? Math.round((facility.revenue / maxRevenue) * 100) : 0,
      percentage: totalRevenue > 0 ? Math.round((facility.revenue / totalRevenue) * 100) : 0,
    }))
  }

  const facilityData = transformFacilityData(facilities)

  // Color palette for different facilities
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
  ]

  if (loading) {
    return (
      <Card className="shadow-sm h-full">
        <CardHeader className="pb-2">
          <CardTitle className="text-[#425166]">Top Facility</CardTitle>
        </CardHeader>
        <CardContent className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="text-[#737791]">Loading facility data...</div>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (error) {
    return (
      <Card className="shadow-sm h-full">
        <CardHeader className="pb-2">
          <CardTitle className="text-[#425166]">Top Facility</CardTitle>
        </CardHeader>
        <CardContent className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="text-red-500 mb-2">Error loading data</div>
            <button onClick={loadFacilityData} className="text-sm text-blue-500 hover:underline">
              Try again
            </button>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (facilityData.length === 0) {
    return (
      <Card className="shadow-sm h-full">
        <CardHeader className="pb-2">
          <CardTitle className="text-[#425166]">Top Facility</CardTitle>
        </CardHeader>
        <CardContent className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="text-[#737791]">No facility data available</div>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="shadow-sm h-full">
      <CardHeader className="pb-2">
        <CardTitle className="text-[#425166]">Top Facility</CardTitle>
      </CardHeader>
      <CardContent className="p-0">
        <div className="overflow-y-auto px-6 max-h-96">
          <table className="w-full table-fixed">
            <thead className="sticky top-0 bg-white z-10">
              <tr className="text-[#737791] text-sm border-b border-gray-200">
                <th className="font-medium text-left pb-3 pt-2 w-12">#</th>
                <th className="font-medium text-left pb-3 pt-2">Name</th>
                <th className="font-medium text-left pb-3 pt-2 w-32">Popularity</th>
                <th className="font-medium text-right pb-3 pt-2 w-20">Share</th>
              </tr>
            </thead>
            <tbody>
              {facilityData.map((facility, index) => (
                <FacilityRow
                  key={facility.facilityId}
                  id={facility.rank.toString().padStart(2, "0")}
                  name={facility.facilityName}
                  progress={facility.progress}
                  color={colors[index % colors.length]}
                  percentage={`${facility.percentage}%`}
                  revenue={facility.revenue}
                />
              ))}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  )
}

interface FacilityRowProps {
  id: string
  name: string
  progress: number
  color: string
  percentage: string
  revenue: number
}

function FacilityRow({ id, name, progress, color, percentage, revenue }: FacilityRowProps) {
  const formatRevenue = (amount: number) => {
    if (amount >= 1000000) {
      return `${(amount / 1000000).toFixed(1)}M đ`
    } else if (amount >= 1000) {
      return `${(amount / 1000).toFixed(0)}k đ`
    }
    return `${amount.toLocaleString()} đ`
  }

  return (
    <tr
      className="border-b border-gray-100 last:border-0 transition-all hover:bg-gray-50 group cursor-pointer"
      title={`${name} - Revenue: ${formatRevenue(revenue)} (${percentage} of total)`}
    >
      <td className="py-4 text-[#425166] w-12">{id}</td>
      <td className="py-4 text-[#425166] pr-4">
        <div className="font-medium group-hover:text-[#4079ed] transition-colors">{name}</div>
      </td>
      <td className="py-4 w-32">
        <Progress value={progress} className="h-2" indicatorColor={color} />
      </td>
      <td className="py-4 text-right w-20">
        <span
          className="inline-block px-3 py-1 rounded-full text-xs font-medium transition-all group-hover:scale-105"
          style={{ backgroundColor: `${color}20`, color: color }}
        >
          {percentage}
        </span>
      </td>
    </tr>
  )
}
