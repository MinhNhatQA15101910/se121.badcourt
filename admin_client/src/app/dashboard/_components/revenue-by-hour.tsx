"use client"

import { useState, useRef, useEffect } from "react"
import { ChevronLeft, ChevronRight } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts"
import { statisticService, type HourlyRevenueStats } from "@/services/statisticService"

export function RevenueByHour() {
  const [selectedYear, setSelectedYear] = useState("2025")
  const [hourlyData, setHourlyData] = useState<HourlyRevenueStats[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const years = ["2021", "2022", "2023", "2024", "2025"]
  const scrollContainerRef = useRef<HTMLDivElement | null>(null)
  const [showLeftArrow, setShowLeftArrow] = useState(false)
  const [showRightArrow, setShowRightArrow] = useState(false)

  // Load data when year changes
  useEffect(() => {
    loadHourlyData()
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedYear])
ư
  const loadHourlyData = async () => {
    try {
      setLoading(true)
      setError(null)
      const year = Number.parseInt(selectedYear)
      const data = await statisticService.getRevenueByHour({ year })
      setHourlyData(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load hourly data")
      console.error("Error loading hourly data:", err)
    } finally {
      setLoading(false)
    }
  }

  // Check scroll position to show/hide arrows
  const checkScroll = () => {
    if (!scrollContainerRef.current) return
    const { scrollLeft, scrollWidth, clientWidth } = scrollContainerRef.current
    setShowLeftArrow(scrollLeft > 0)
    setShowRightArrow(scrollLeft < scrollWidth - clientWidth - 5)
  }

  useEffect(() => {
    const container = scrollContainerRef.current
    if (container) {
      container.addEventListener("scroll", checkScroll)
      checkScroll()
      setTimeout(checkScroll, 500)
    }

    return () => {
      if (container) {
        container.removeEventListener("scroll", checkScroll)
      }
    }
  }, [hourlyData])

  const scroll = (direction: "left" | "right") => {
    if (!scrollContainerRef.current) return
    const scrollAmount = 200
    scrollContainerRef.current.scrollBy({
      left: direction === "left" ? -scrollAmount : scrollAmount,
      behavior: "smooth",
    })
  }

  // Transform API data to chart format
  const transformDataForChart = (data: HourlyRevenueStats[]) => {
    return data.map((item) => ({
      hour: item.hourRange,
      revenue: Math.round(item.revenue / 1000), // Convert to thousands
      originalRevenue: item.revenue,
    }))
  }

  const chartData = transformDataForChart(hourlyData)

  // Calculate peak hours and total revenue
  const peakHour =
    chartData.length > 0
      ? chartData.reduce((max, current) => (current.revenue > max.revenue ? current : max), chartData[0])
      : null
  const totalRevenue = hourlyData.reduce((sum, item) => sum + item.revenue, 0)
  const activeHours = hourlyData.filter((item) => item.revenue > 0).length

  if (loading) {
    return (
      <Card className="shadow-sm h-full flex flex-col">
        <CardHeader className="pb-2 flex flex-row items-center justify-between">
          <CardTitle className="text-[#425166]">Revenue by Hour</CardTitle>
          <Select value={selectedYear} onValueChange={setSelectedYear}>
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
        <CardContent className="flex-1 flex items-center justify-center">
          <div className="text-center">
            <div className="text-[#737791]">Loading hourly data...</div>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (error) {
    return (
      <Card className="shadow-sm h-full flex flex-col">
        <CardHeader className="pb-2 flex flex-row items-center justify-between">
          <CardTitle className="text-[#425166]">Revenue by Hour</CardTitle>
          <Select value={selectedYear} onValueChange={setSelectedYear}>
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
        <CardContent className="flex-1 flex items-center justify-center">
          <div className="text-center">
            <div className="text-red-500 mb-2">Error loading data</div>
            <button onClick={loadHourlyData} className="text-sm text-blue-500 hover:underline">
              Try again
            </button>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (hourlyData.length === 0) {
    return (
      <Card className="shadow-sm h-full flex flex-col">
        <CardHeader className="pb-2 flex flex-row items-center justify-between">
          <CardTitle className="text-[#425166]">Revenue by Hour</CardTitle>
          <Select value={selectedYear} onValueChange={setSelectedYear}>
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
        <CardContent className="flex-1 flex items-center justify-center">
          <div className="text-center">
            <div className="text-[#737791]">No hourly data available for {selectedYear}</div>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="shadow-sm h-full flex flex-col">
      <CardHeader className="pb-2 flex flex-row items-center justify-between">
        <div>
          <CardTitle className="text-[#425166]">Revenue by Hour ({selectedYear})</CardTitle>
          <div className="text-sm text-[#737791] mt-1">
            {peakHour && peakHour.revenue > 0 ? (
              <>
                Peak: {peakHour.hour} • Active Hours: {activeHours}/24 • Total: {Math.round(totalRevenue / 1000)}k đ
              </>
            ) : (
              <>No activity recorded for {selectedYear}</>
            )}
          </div>
        </div>
        <Select value={selectedYear} onValueChange={setSelectedYear}>
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
      <CardContent className="flex-1 flex flex-col">
        <div className="relative flex-1">
          {showLeftArrow && (
            <button
              className="absolute left-0 top-1/2 -translate-y-1/2 z-10 bg-white/80 rounded-full p-1 shadow-md hover:bg-white transition-colors"
              onClick={() => scroll("left")}
            >
              <ChevronLeft size={20} />
            </button>
          )}
          <div ref={scrollContainerRef} className="overflow-x-auto w-full h-[300px] custom-scrollbar">
            <div className="min-w-[1200px] h-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData} margin={{ top: 20, right: 30, left: 0, bottom: 5 }}>
                  <defs>
                    <linearGradient id="hourlyRevenueGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#bf83ff" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="#bf83ff" stopOpacity={0.2} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis
                    dataKey="hour"
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "#737791", fontSize: 11 }}
                    angle={-45}
                    textAnchor="end"
                    height={80}
                  />
                  <YAxis axisLine={false} tickLine={false} tick={{ fill: "#737791", fontSize: 12 }} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "white",
                      borderRadius: "8px",
                      boxShadow: "0 4px 12px rgba(0,0,0,0.1)",
                      border: "none",
                    }}
                    itemStyle={{ padding: "2px 0" }}
                    labelStyle={{ fontWeight: "bold", marginBottom: "5px" }}
                    formatter={(value, name, props) => {
                      const originalRevenue = props.payload?.originalRevenue || 0
                      if (originalRevenue === 0) {
                        return ["No activity", "Revenue"]
                      }
                      return [`${value}k đ`, "Revenue"]
                    }}
                    labelFormatter={(label) => `Time: ${label} (${selectedYear})`}
                  />
                  <Bar
                    dataKey="revenue"
                    name="Revenue"
                    fill="url(#hourlyRevenueGradient)"
                    radius={[4, 4, 0, 0]}
                    barSize={30}
                    animationDuration={1500}
                    animationEasing="ease-out"
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
          {showRightArrow && (
            <button
              className="absolute right-0 top-1/2 -translate-y-1/2 z-10 bg-white/80 rounded-full p-1 shadow-md hover:bg-white transition-colors"
              onClick={() => scroll("right")}
            >
              <ChevronRight size={20} />
            </button>
          )}
        </div>
        <div className="mt-4 flex justify-center">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#bf83ff]"></div>
            <span className="text-sm text-[#737791]">Revenue (thousand đ)</span>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
