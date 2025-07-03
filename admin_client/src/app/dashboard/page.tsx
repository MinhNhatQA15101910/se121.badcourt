"use client"

import LoadingScreen from "@/components/loading-creen"
import { useSession } from "next-auth/react"
import { useRouter } from "next/navigation"
import { useEffect } from "react"
import { MonthlyRevenue } from "./_components/monthly-revenue"
import { MonthlyUsers } from "./_components/monthly-users"
import { RevenueByHour } from "./_components/revenue-by-hour"
import { RevenueByRegion } from "./_components/revenue-by-region"
import { RevenueSummary } from "./_components/revenue-summary"
import { TodayRevenue } from "./_components/today-revenue"
import { TopFacility } from "./_components/top-facility"

export default function DashboardPage() {
  const { status } = useSession()
  const router = useRouter()

  useEffect(() => {
    // If user is not authenticated, redirect to login
    if (status === "unauthenticated") {
      router.replace("/login")
    }
  }, [status, router])

  // Show loading state while checking authentication
  if (status === "loading") {
    return <LoadingScreen />
  }

  // Only render the actual content if authenticated
  if (status === "authenticated") {
    return (
      <div className="bg-[#fafbfc] min-h-full w-full p-6 overflow-y-auto">
        <div className="grid grid-cols-12 gap-6 overflow-y-auto">
          {/* Top Row - Revenue Summary (Full Width) */}
          <div className="col-span-12">
            <RevenueSummary />
          </div>

          {/* Middle Row */}
          <div className="col-span-12 grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Today's Revenue with Date Range */}
            <div className="col-span-1">
              <TodayRevenue />
            </div>
            {/* Top Facility */}
            <div className="col-span-1">
              <TopFacility />
            </div>
          </div>

          {/* Charts Row 1 */}
          <div className="col-span-12 grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Monthly Users */}
            <div className="col-span-1">
              <MonthlyUsers />
            </div>
            {/* Monthly Revenue/Profit */}
            <div className="col-span-1">
              <MonthlyRevenue />
            </div>
          </div>

          {/* Charts Row 2 */}
          <div className="col-span-12 grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Revenue by Region */}
            <div className="col-span-1">
              <RevenueByRegion />
            </div>
            {/* Revenue by Hour */}
            <div className="col-span-1">
              <RevenueByHour />
            </div>
          </div>
        </div>
      </div>
    )
  }

  // Return empty div while redirecting
  return <div></div>
}
