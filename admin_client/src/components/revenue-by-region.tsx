"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Progress } from "@/components/ui/progress"

export function RevenueByRegion() {
  const [selectedYear, setSelectedYear] = useState("2023")
  const years = ["2021", "2022", "2023", "2024"]

  // Generate data based on year
  const getDataForYear = (year: string) => {
    const baseData = [
      { id: "01", region: "Quận 1", revenue: 85000000, percentage: 25, color: "#4079ed" },
      { id: "02", region: "Quận 7", revenue: 65000000, percentage: 19, color: "#23c16b" },
      { id: "03", region: "Quận 2", revenue: 55000000, percentage: 16, color: "#bf83ff" },
      { id: "04", region: "Quận 3", revenue: 45000000, percentage: 13, color: "#ff8900" },
      { id: "05", region: "Quận 10", revenue: 35000000, percentage: 10, color: "#fa5a7d" },
      { id: "06", region: "Quận Bình Thạnh", revenue: 25000000, percentage: 7, color: "#00bcd4" },
      { id: "07", region: "Quận Tân Bình", revenue: 20000000, percentage: 6, color: "#ff5722" },
      { id: "08", region: "Quận Phú Nhuận", revenue: 15000000, percentage: 4, color: "#9c27b0" },
      { id: "09", region: "Quận Gò Vấp", revenue: 12000000, percentage: 3, color: "#607d8b" },
      { id: "10", region: "Quận 4", revenue: 10000000, percentage: 3, color: "#795548" },
      { id: "11", region: "Quận 5", revenue: 8000000, percentage: 2, color: "#8bc34a" },
      { id: "12", region: "Quận 6", revenue: 5000000, percentage: 1, color: "#ffc107" },
    ]

    // Modify data based on year
    const yearFactor = Number.parseInt(year) - 2021
    return baseData
      .map((item) => {
        const variationFactor = 1 + yearFactor * 0.1 * (Math.random() > 0.5 ? 1 : -1)
        const newRevenue = Math.round(item.revenue * variationFactor)
        return {
          ...item,
          revenue: newRevenue,
        }
      })
      .sort((a, b) => b.revenue - a.revenue) // Sort by revenue descending
  }

  const data = getDataForYear(selectedYear)

  // Calculate total revenue and percentages
  const totalRevenue = data.reduce((sum, item) => sum + item.revenue, 0)
  const dataWithPercentages = data.map((item) => ({
    ...item,
    percentage: Math.round((item.revenue / totalRevenue) * 100),
  }))

  return (
    <Card className="shadow-sm h-full">
      <CardHeader className="pb-2 flex flex-row items-center justify-between">
        <CardTitle className="text-[#425166]">Revenue by Region</CardTitle>
        <Select value={selectedYear} onValueChange={(value) => setSelectedYear(value)}>
          <SelectTrigger className="w-[100px] h-8">
            <SelectValue placeholder="Year" />
          </SelectTrigger>
          <SelectContent>
            {years.map((year) => (
              <SelectItem key={year} value={year}>
                {year}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </CardHeader>
      <CardContent className="p-0">
        <div className="max-h-[350px] overflow-y-auto px-6 pb-6">
          <table className="w-full">
            <thead className="sticky top-0 bg-white z-10">
              <tr className="text-[#737791] text-sm">
                <th className="font-normal text-left pb-2 pt-2">#</th>
                <th className="font-normal text-left pb-2 pt-2">Region</th>
                <th className="font-normal text-left pb-2 pt-2">Revenue</th>
                <th className="font-normal text-left pb-2 pt-2">Percentage</th>
              </tr>
            </thead>
            <tbody>
              {dataWithPercentages.map((item, index) => (
                <RegionRow
                  key={item.id}
                  id={item.id}
                  region={item.region}
                  revenue={item.revenue.toLocaleString()}
                  progress={item.percentage}
                  color={item.color}
                  percentage={`${item.percentage}%`}
                  delay={index * 0.1}
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
  revenue: string
  progress: number
  color: string
  percentage: string
  delay?: number
}

// Đổi <div> thành <tr> để tránh lỗi hiển thị bảng
function RegionRow({ id, region, revenue, progress, color, percentage }: RegionRowProps) {
  return (
    <tr className="border-b border-gray-100 last:border-0">
      <td className="py-3 text-[#425166]">{id}</td>
      <td className="py-3 text-[#425166]">{region}</td>
      <td className="py-3 text-[#425166]">{revenue} đ</td>
      <td className="py-3 w-1/3">
        <div className="flex items-center gap-2">
          <Progress value={progress} className="h-2 flex-1" indicatorColor={color} />
          <span
            className="inline-block px-2 py-1 rounded-full text-xs font-medium whitespace-nowrap"
            style={{ backgroundColor: `${color}20`, color: color }}
          >
            {percentage}
          </span>
        </div>
      </td>
    </tr>
  )
}
