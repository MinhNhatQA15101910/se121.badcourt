"use client";

import React, { useState } from "react";
import { PieChart, FileText, Users, Download } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { DatePicker } from "@/components/ui/date-picker";

export function TodayRevenue() {
  const [startDate, setStartDate] = useState<Date | undefined>(new Date());
  const [endDate, setEndDate] = useState<Date | undefined>(new Date());

  return (
    <Card className="shadow-sm h-full">
      <CardHeader className="pb-2 flex flex-row items-center justify-between">
        <div>
          <CardTitle className="text-[#425166]">Revenue Summary</CardTitle>
          <CardDescription>Booking summary by date range</CardDescription>
        </div>
        <Button variant="outline" size="sm" className="h-8">
          <Download size={14} className="mr-2" />
          Export
        </Button>
      </CardHeader>
      <CardContent>
        {/* Date Picker Section */}
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          <div className="flex-1">
            <label className="text-sm text-[#737791] mb-1 block">Start Date</label>
            <DatePicker date={startDate} setDate={setStartDate} />
            </div>
          <div className="flex-1">
            <label className="text-sm text-[#737791] mb-1 block">End Date</label>
            <DatePicker date={endDate} setDate={setEndDate} />
            </div>
        </div>

        {/* Stats Section */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <StatCard
            icon={<PieChart size={20} />}
            iconBg="bg-[#fa5a7d]"
            iconBgLight="bg-[#ffe2e5]"
            value="100.000k đ"
            label="Total profit"
            change="+8% from previous period"
          />
          <StatCard
            icon={<FileText size={20} />}
            iconBg="bg-[#ff8900]"
            iconBgLight="bg-[#fff4de]"
            value="300"
            label="Total Booking"
            change="+5% from previous period"
          />
          <StatCard
            icon={<Users size={20} />}
            iconBg="bg-[#23c16b]"
            iconBgLight="bg-[#dcfce7]"
            value="5"
            label="New facility owner"
            change="+12% from previous period"
          />
          <StatCard
            icon={<Users size={20} />}
            iconBg="bg-[#bf83ff]"
            iconBgLight="bg-[#f3e8ff]"
            value="8"
            label="New Customers"
            change="+0.5% from previous period"
          />
        </div>
      </CardContent>
    </Card>
  );
}

// StatCard Component
interface StatCardProps {
  icon: React.ReactNode;
  iconBg: string;
  iconBgLight: string;
  value: string;
  label: string;
  change: string;
}

export function StatCard({ icon, iconBg, iconBgLight, value, label, change }: StatCardProps) {
  const isPositive = change.startsWith("+");

  return (
    <div className={`p-4 rounded-lg ${iconBgLight} transform transition-all duration-300 hover:scale-105`}>
      <div className="flex items-center gap-3 mb-2">
        <div className={`w-10 h-10 rounded-full ${iconBg} flex items-center justify-center text-white`}>
          {icon}
        </div>
      </div>
      <div className="text-xl font-bold">{value}</div>
      <div className="text-sm">{label}</div>
      <div className={`text-xs mt-1 ${isPositive ? "text-[#23c16b]" : "text-[#fa5a7d]"}`}>{change}</div>
    </div>
  );
}
