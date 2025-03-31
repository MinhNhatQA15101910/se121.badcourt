"use client"

import LoadingScreen from "@/components/loading-creen"
import { MonthlyRevenue } from "@/components/monthly-revenue"
import { MonthlyUsers } from "@/components/monthly-users"
import { RevenueByHour } from "@/components/revenue-by-hour"
import { RevenueByRegion } from "@/components/revenue-by-region"
import { TodayRevenue } from "@/components/today-revenue"
import { TopFacility } from "@/components/top-facility"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Minus, PieChart, Plus, Users } from "lucide-react"
import { useSession } from "next-auth/react"
import { useRouter } from "next/navigation"
import { useEffect } from "react"

export default function DashboardPage() {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const { data: session, status } = useSession()
  const router = useRouter()

  useEffect(() => {
    // If user is not authenticated, redirect to login
    if (status === "unauthenticated") {
      router.replace("/login")
    }
  }, [status, router])

  // Show loading state while checking authentication
  if (status === "loading") {
    return (
      <LoadingScreen/>
    )
  }

  // Only render the actual content if authenticated
  if (status === "authenticated") {
    return (
      <div className="bg-[#fafbfc] min-h-full w-full p-6 overflow-y-auto">
      <div className="grid grid-cols-12 gap-6 overflow-y-auto">
        {/* Top Row */}
        <div className="col-span-12 grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Commission Fee */}
          <Card className="shadow-sm h-full">
            <CardHeader className="pb-2">
              <CardTitle className="text-[#425166]">Commission Fee Percentage</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div className="bg-[#dcfce7] p-4 rounded-lg flex items-center gap-3 transform transition-all duration-300 hover:scale-105">
                  <div className="w-10 h-10 rounded-full bg-[#23c16b] flex items-center justify-center">
                    <PieChart className="text-white" size={20} />
                  </div>
                  <span className="text-3xl font-bold">10%</span>
                </div>
                <div className="space-y-2">
                  <Button variant="outline" size="icon" className="h-8 w-8">
                    <Plus size={16} />
                  </Button>
                  <Button variant="outline" size="icon" className="h-8 w-8">
                    <Minus size={16} />
                  </Button>
                </div>
              </div>

              <div className="mt-6 grid grid-cols-2 gap-4">
                <div>
                  <div className="text-sm text-[#737791]">Last Update</div>
                  <div className="text-2xl font-bold">9%</div>
                </div>
                <div>
                  <div className="text-sm text-[#737791]">Since</div>
                  <div className="text-2xl font-bold">21/9/2023</div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Total Revenue */}
          <Card className="shadow-sm md:col-span-2 h-full">
            <CardHeader className="pb-2">
              <CardTitle className="text-[#425166]">Total Revenue</CardTitle>
              <CardDescription>Total booking</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <StatCard
                  icon={<PieChart size={20} />}
                  iconBg="bg-[#fa5a7d]"
                  iconBgLight="bg-[#ffe2e5]"
                  value="100.000k đ"
                  label="Total profit"
                  change="+8% from yesterday"
                />
                <StatCard
                  icon={<Users size={20} />}
                  iconBg="bg-[#23c16b]"
                  iconBgLight="bg-[#dcfce7]"
                  value="500"
                  label="Total facility owner"
                  change="+12% from yesterday"
                />
                <StatCard
                  icon={<Users size={20} />}
                  iconBg="bg-[#bf83ff]"
                  iconBgLight="bg-[#f3e8ff]"
                  value="1000"
                  label="Total Customers"
                  change="0.5% from yesterday"
                />
              </div>
            </CardContent>
          </Card>
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
          {/* Monthly Users (replacing Volume vs Service Level) */}
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

interface StatCardProps {
  icon: React.ReactNode
  iconBg: string
  iconBgLight: string
  value: string
  label: string
  change: string
}

function StatCard({ icon, iconBg, iconBgLight, value, label, change }: StatCardProps) {
  const isPositive = change.startsWith("+")

  return (
    <div className={`p-4 rounded-lg ${iconBgLight} transform transition-all duration-300 hover:scale-105`}>
      <div className="flex items-center gap-3 mb-2">
        <div className={`w-10 h-10 rounded-full ${iconBg} flex items-center justify-center text-white`}>{icon}</div>
      </div>
      <div className="text-xl font-bold">{value}</div>
      <div className="text-sm">{label}</div>
      <div className={`text-xs mt-1 ${isPositive ? "text-[#23c16b]" : "text-[#fa5a7d]"}`}>{change}</div>
    </div>
  )
}

