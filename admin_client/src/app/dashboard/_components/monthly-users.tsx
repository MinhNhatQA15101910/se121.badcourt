"use client"

import { useState, useRef, useEffect } from "react"
import { ChevronLeft, ChevronRight } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts"
import { statisticService, type MonthlyUserStats } from "@/services/statisticService"

export function MonthlyUsers() {
  const [selectedYear, setSelectedYear] = useState("2025")
  const [userStats, setUserStats] = useState<MonthlyUserStats[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const years = ["2021", "2022", "2023", "2024", "2025"]
  const scrollContainerRef = useRef<HTMLDivElement | null>(null)
  const [showLeftArrow, setShowLeftArrow] = useState(false)
  const [showRightArrow, setShowRightArrow] = useState(false)

  // Load data when year changes
  useEffect(() => {
    loadUserStats()
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedYear])

  const loadUserStats = async () => {
    try {
      setLoading(true)
      setError(null)
      const year = Number.parseInt(selectedYear)
      const data = await statisticService.getUserStats({ year })
      setUserStats(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load user statistics")
      console.error("Error loading user stats:", err)
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
  }, [userStats])

  const scroll = (direction: "left" | "right") => {
    if (!scrollContainerRef.current) return
    const scrollAmount = 200
    const currentScroll = scrollContainerRef.current.scrollLeft
    scrollContainerRef.current.scrollTo({
      left: direction === "left" ? currentScroll - scrollAmount : currentScroll + scrollAmount,
      behavior: "smooth",
    })
  }

  // Transform API data to chart format
  const transformDataForChart = (stats: MonthlyUserStats[]) => {
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    return stats.map((stat) => ({
      name: monthNames[stat.month - 1],
      Players: stat.players,
      "Facility Owners": stat.managers, // Using managers as facility owners
    }))
  }

  const chartData = transformDataForChart(userStats)

  if (loading) {
    return (
      <Card className="shadow-sm h-full flex flex-col">
        <CardHeader className="pb-2 flex flex-row items-center justify-between">
          <CardTitle className="text-[#425166]">Monthly Users</CardTitle>
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
            <div className="text-[#737791]">Loading user statistics...</div>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (error) {
    return (
      <Card className="shadow-sm h-full flex flex-col">
        <CardHeader className="pb-2 flex flex-row items-center justify-between">
          <CardTitle className="text-[#425166]">Monthly Users</CardTitle>
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
            <button onClick={loadUserStats} className="text-sm text-blue-500 hover:underline">
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
        <CardTitle className="text-[#425166]">Monthly Users</CardTitle>
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
                    <linearGradient id="playersGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#4079ed" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="#4079ed" stopOpacity={0.2} />
                    </linearGradient>
                    <linearGradient id="ownersGradient" x1="0" y1="0" x2="0" y2="1">
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
                  />
                  <Bar
                    dataKey="Players"
                    fill="url(#playersGradient)"
                    radius={[4, 4, 0, 0]}
                    barSize={20}
                    animationDuration={1500}
                    animationEasing="ease-out"
                  />
                  <Bar
                    dataKey="Facility Owners"
                    fill="url(#ownersGradient)"
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
            <span className="text-sm text-[#737791]">Players</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#23c16b]"></div>
            <span className="text-sm text-[#737791]">Facility Owners</span>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
