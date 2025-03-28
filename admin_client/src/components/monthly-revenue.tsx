"use client"

import { useState, useRef, useEffect } from "react"
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts"

export function MonthlyRevenue() {
  const [selectedYear, setSelectedYear] = useState("2023")
  const years = ["2021", "2022", "2023", "2024"]
  const scrollContainerRef = useRef<HTMLDivElement | null>(null)
  const [showLeftArrow, setShowLeftArrow] = useState(false)
  const [showRightArrow, setShowRightArrow] = useState(false)

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
      // Initial check
      checkScroll()

      // Check after content might have changed
      setTimeout(checkScroll, 500)
    }

    return () => {
      if (container) {
        container.removeEventListener("scroll", checkScroll)
      }
    }
  }, [])

  const scroll = (direction: 'left' | 'right') => {
    if (!scrollContainerRef.current) return

    const scrollAmount = 200
    const currentScroll = scrollContainerRef.current.scrollLeft
    scrollContainerRef.current.scrollTo({
      left: direction === 'left' ? currentScroll - scrollAmount : currentScroll + scrollAmount,
      behavior: 'smooth'
    })
  }

  // Generate data based on year
  const getDataForYear = (year: string) => {
    const baseData = [
      { name: 'Jan', Revenue: 12, Profit: 10 },
      { name: 'Feb', Revenue: 15, Profit: 12 },
      { name: 'Mar', Revenue: 8, Profit: 25 },
      { name: 'Apr', Revenue: 14, Profit: 6 },
      { name: 'May', Revenue: 12, Profit: 10 },
      { name: 'Jun', Revenue: 18, Profit: 14 },
      { name: 'Jul', Revenue: 20, Profit: 10 },
      { name: 'Aug', Revenue: 16, Profit: 8 },
      { name: 'Sep', Revenue: 14, Profit: 7 },
      { name: 'Oct', Revenue: 12, Profit: 6 },
      { name: 'Nov', Revenue: 10, Profit: 5 },
      { name: 'Dec', Revenue: 22, Profit: 12 },
    ]

    // Modify data based on year to show different patterns
    const yearFactor = parseInt(year) - 2021
    return baseData.map(item => ({
      ...item,
      Revenue: Math.max(5, item.Revenue + yearFactor * 4 * (Math.random() > 0.5 ? 1 : -1)),
      Profit: Math.max(3, item.Profit + yearFactor * 3 * (Math.random() > 0.5 ? 1 : -1))
    }))
  }

  const data = getDataForYear(selectedYear)

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
                <BarChart data={data} margin={{ top: 20, right: 30, left: 0, bottom: 5 }}>
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
                    formatter={(value) => [`${value}k`, null]}
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
