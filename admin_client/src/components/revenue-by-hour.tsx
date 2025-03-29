"use client"

import { useState, useRef, useEffect } from "react"
import { ChevronLeft, ChevronRight } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts"

export function RevenueByHour() {
  const [selectedYear, setSelectedYear] = useState("2023")
  const years = ["2021", "2022", "2023", "2024"]
  const scrollContainerRef = useRef<HTMLDivElement | null>(null)
  const [showLeftArrow, setShowLeftArrow] = useState(false)
  const [showRightArrow, setShowRightArrow] = useState(false)
  const [isDropdownOpen, setIsDropdownOpen] = useState(false)

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
      // Initial check
      checkScroll()
    }

    return () => {
      if (container) {
        container.removeEventListener("scroll", checkScroll)
      }
    }
  }, [selectedYear]) // Re-run when the year changes

  // Re-check scroll when dropdown closes
  useEffect(() => {
    if (!isDropdownOpen) {
      setTimeout(checkScroll, 100) // Small delay to ensure DOM is updated
    }
  }, [isDropdownOpen])

  const scroll = (direction: "left" | "right") => {
    if (!scrollContainerRef.current) return

    const scrollAmount = 200
    scrollContainerRef.current.scrollBy({
      left: direction === "left" ? -scrollAmount : scrollAmount,
      behavior: "smooth",
    })
  }

  // Generate data based on year
  const getDataForYear = (year: string) => {
    const baseData = [
      { hour: "6:00", revenue: 5 },
      { hour: "7:00", revenue: 12 },
      { hour: "8:00", revenue: 18 },
      { hour: "9:00", revenue: 15 },
      { hour: "10:00", revenue: 10 },
      { hour: "11:00", revenue: 8 },
      { hour: "12:00", revenue: 7 },
      { hour: "13:00", revenue: 9 },
      { hour: "14:00", revenue: 12 },
      { hour: "15:00", revenue: 15 },
      { hour: "16:00", revenue: 20 },
      { hour: "17:00", revenue: 25 },
      { hour: "18:00", revenue: 30 },
      { hour: "19:00", revenue: 28 },
      { hour: "20:00", revenue: 22 },
      { hour: "21:00", revenue: 15 },
      { hour: "22:00", revenue: 8 },
    ]

    // Thay đổi cách tạo dữ liệu để tránh Math.random()
    const yearFactor = Number.parseInt(year) - 2021
    return baseData.map((item) => ({
      ...item,
      revenue: Math.max(2, item.revenue + yearFactor * 2), // Không dùng random
    }))
  }

  const data = getDataForYear(selectedYear)

  return (
    <Card className="shadow-sm h-full flex flex-col">
      <CardHeader className="pb-2 flex flex-row items-center justify-between">
        <CardTitle className="text-[#425166]">Revenue by Hour</CardTitle>
        <Select value={selectedYear} onValueChange={setSelectedYear} onOpenChange={(open) => setIsDropdownOpen(open)}>
          <SelectTrigger className="w-[100px] h-8">
            <SelectValue placeholder="Year" />
          </SelectTrigger>
          <SelectContent position="popper" sideOffset={5}>
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

          <div ref={scrollContainerRef} className="overflow-x-auto w-full h-[300px] custom-scrollbar">
            <div className="min-w-[800px] h-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={data} margin={{ top: 20, right: 30, left: 0, bottom: 5 }}>
                  <defs>
                    <linearGradient id="hourlyRevenueGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#bf83ff" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="#bf83ff" stopOpacity={0.2} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="hour" axisLine={false} tickLine={false} tick={{ fill: "#737791", fontSize: 12 }} />
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
                    formatter={(value) => [`${value}k đ`, "Revenue"]}
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
              className="absolute right-0 top-1/2 -translate-y-1/2 z-10 bg-white/80 rounded-full p-1 shadow-md"
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

