"use client"

import { useState, useRef, useEffect } from "react"
import { ChevronLeft, ChevronRight } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts"
import { statisticService, type MonthlyRevenueStats } from "@/services/statisticService"

export function MonthlyRevenue() {
  const [selectedYear, setSelectedYear] = useState("2025")
  const [revenueStats, setRevenueStats] = useState<MonthlyRevenueStats[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const years = ["2021", "2022", "2023", "2024", "2025"]
  const scrollContainerRef = useRef<HTMLDivElement | null>(null)
  const [showLeftArrow, setShowLeftArrow] = useState(false)
  const [showRightArrow, setShowRightArrow] = useState(false)

  // Load data when year changes
  useEffect(() => {
    loadRevenueStats()
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedYear])

  const loadRevenueStats = async () => {
    try {
      setLoading(true)
      setError(null)
      const year = Number.parseInt(selectedYear)
      const data = await statisticService.getRevenueStats({ year })
      setRevenueStats(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load revenue statistics")
      console.error("Error loading revenue stats:", err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    const checkScroll = () => {
      if (!scrollContainerRef.current) return
      const { scrollLeft, scrollWidth, clientWidth } = scrollContainerRef.current
      setShowLeftArrow(scrollLeft > 0)
      setShowRightArrow(scrollLeft < scrollWidth - clientWidth - 5)
    }

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
  }, [revenueStats])

  const scroll = (direction: "left" | "right") => {
    if (!scrollContainerRef.current) return
    const scrollAmount = 200
    const currentScroll = scrollContainerRef.current.scrollLeft
    scrollContainerRef.current.scrollTo({
      left: direction === "left" ? currentScroll - scrollAmount : currentScroll + scrollAmount,
      behavior: "smooth",
    })
  }

  // Transform API data to chart format - show all 12 months, empty if no data
  const transformDataForChart = (stats: MonthlyRevenueStats[]) => {
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    // Create a map for quick lookup
    const statsMap = new Map(stats.map((stat) => [stat.month, stat]))

    // Generate all 12 months, with empty values if no data
    return monthNames.map((name, index) => {
      const monthNumber = index + 1
      const stat = statsMap.get(monthNumber)

      return {
        name,
        Revenue: stat ? Math.round(stat.revenue / 1000) : 0, // Convert to thousands and round
        Profit: stat ? Math.round((stat.revenue * 0.1) / 1000) : 0, // Assume 10% profit margin, convert to thousands
        hasData: !!stat, // Track if this month has actual data
      }
    })
  }

  const chartData = transformDataForChart(revenueStats)

  if (loading) {
    return (
      <Card className="shadow-sm h-full flex flex-col">
        <CardHeader className="pb-2 flex flex-row items-center justify-between">
          <CardTitle className="text-[#425166]">Monthly Revenue/Profit</CardTitle>
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
            <div className="text-[#737791]">Loading revenue statistics...</div>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (error) {
    return (
      <Card className="shadow-sm h-full flex flex-col">
        <CardHeader className="pb-2 flex flex-row items-center justify-between">
          <CardTitle className="text-[#425166]">Monthly Revenue/Profit</CardTitle>
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
            <button onClick={loadRevenueStats} className="text-sm text-blue-500 hover:underline">
              Try again
            </button>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="shadow-sm h-full flex flex-col">
      <CardHeader className="pb-2 flex flex-row items-center justify-between">
        <CardTitle className="text-[#425166]">Monthly Revenue/Profit</CardTitle>
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
              className="absolute left-0 top-1/2 -translate-y-1/2 z-10 bg-white/80 rounded-full p-1 shadow-md"
              onClick={() => scroll("left")}
            >
              <ChevronLeft size={20} />
            </button>
          )}
          <div
            ref={scrollContainerRef}
            className="overflow-x-auto scrollbar-hide h-[300px] w-full"
            style={{ scrollbarWidth: "none", msOverflowStyle: "none" }}
          >
            <div className="min-w-[500px] h-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData} margin={{ top: 20, right: 30, left: 0, bottom: 5 }}>
                  <defs>
                    <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#4079ed" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="#4079ed" stopOpacity={0.2} />
                    </linearGradient>
                    <linearGradient id="profitGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#23c16b" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="#23c16b" stopOpacity={0.2} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: "#737791", fontSize: 12 }} />
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
                    formatter={(value, name) => {
                      if (value === 0) return ["No data", name]
                      return [`${value}k đ`, name]
                    }}
                  />
                  <Bar
                    dataKey="Revenue"
                    fill="url(#revenueGradient)"
                    radius={[4, 4, 0, 0]}
                    barSize={20}
                    animationDuration={1500}
                    animationEasing="ease-out"
                  />
                  <Bar
                    dataKey="Profit"
                    fill="url(#profitGradient)"
                    radius={[4, 4, 0, 0]}
                    barSize={20}
                    animationDuration={1500}
                    animationEasing="ease-out"
                    animationBegin={300}
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
          {showRightArrow && (
            <button
              className="absolute right-0 top-1/2 -translate-y-1/2 z-10 bg-white/80 rounded-full p-1 shadow-md"
              onClick={() => scroll("right")}
            >
              <ChevronRight size={20} />
            </button>
          )}
        </div>
        <div className="mt-4 flex justify-center gap-8">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#4079ed]"></div>
            <span className="text-sm text-[#737791]">Revenue</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#23c16b]"></div>
            <span className="text-sm text-[#737791]">Profit</span>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
