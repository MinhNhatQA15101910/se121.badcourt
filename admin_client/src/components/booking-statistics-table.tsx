"use client";

import React, { useState, useEffect } from "react";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

interface Booking {
  id: string;
  playerId: string;
  playtime: string;
  courtName: string;
  revenue: number;
}

interface BookingStatisticsTableProps {
  bookings: Booking[];
}

export function BookingStatisticsTable({ bookings }: BookingStatisticsTableProps) {
  const [year, setYear] = useState<string>("all");
  const [month, setMonth] = useState<string>("all");
  const [court, setCourt] = useState<string>("all");
  const [filteredBookings, setFilteredBookings] = useState<Booking[]>(bookings);

  // Get unique years and courts from bookings
  const years = Array.from(
    new Set(
      bookings.map((booking) => {
        const date = new Date(booking.playtime.split(",")[0]);
        return date.getFullYear().toString();
      })
    )
  ).sort((a, b) => parseInt(b) - parseInt(a));

  const courts = Array.from(new Set(bookings.map((booking) => booking.courtName))).sort();

  // Handle year change
  const handleYearChange = (value: string) => {
    setYear(value);
    if (value === "all") {
      setMonth("all"); // Force month to be "all" when year is "all"
    }
  };

  // Handle month change
  const handleMonthChange = (value: string) => {
    // If year is "all", month must be "all"
    if (year === "all" && value !== "all") {
      return;
    }
    setMonth(value);
  };

  // Filter bookings based on selected filters
  useEffect(() => {
    let filtered = [...bookings];

    if (year !== "all") {
      filtered = filtered.filter((booking) => {
        const date = new Date(booking.playtime.split(",")[0]);
        return date.getFullYear().toString() === year;
      });

      if (month !== "all") {
        filtered = filtered.filter((booking) => {
          const date = new Date(booking.playtime.split(",")[0]);
          return date.getMonth() + 1 === parseInt(month);
        });
      }
    }

    if (court !== "all") {
      filtered = filtered.filter((booking) => booking.courtName === court);
    }

    setFilteredBookings(filtered);
  }, [year, month, court, bookings]);

  // Calculate total revenue
  const totalRevenue = filteredBookings.reduce((sum, booking) => sum + booking.revenue, 0);

  return (
    <div className="space-y-4">
      <h4 className="font-medium text-sm">Booking Statistics</h4>

      <div className="flex flex-wrap gap-4 mb-4">
        <div className="w-full sm:w-auto">
          <label className="block text-sm text-[#808089] mb-1">Year</label>
          <Select value={year} onValueChange={handleYearChange}>
            <SelectTrigger className="w-[140px]">
              <SelectValue placeholder="Select Year" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Years</SelectItem>
              {years.map((y) => (
                <SelectItem key={y} value={y}>
                  {y}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="w-full sm:w-auto">
          <label className="block text-sm text-[#808089] mb-1">Month</label>
          <Select 
            value={month} 
            onValueChange={handleMonthChange}
            disabled={year === "all"}
          >
            <SelectTrigger className={`w-[140px] ${year === "all" ? "opacity-70" : ""}`}>
              <SelectValue placeholder="Select Month" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Months</SelectItem>
              {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => (
                <SelectItem key={m} value={m.toString()}>
                  {new Date(2000, m - 1, 1).toLocaleString("default", { month: "long" })}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="w-full sm:w-auto">
          <label className="block text-sm text-[#808089] mb-1">Court</label>
          <Select value={court} onValueChange={setCourt}>
            <SelectTrigger className="w-[140px]">
              <SelectValue placeholder="Select Court" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Courts</SelectItem>
              {courts.map((c) => (
                <SelectItem key={c} value={c}>
                  {c}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full border-collapse">
          <thead>
            <tr className="bg-[#f2f2f2]">
              <th className="text-left p-2 text-sm font-medium text-[#4b4b4b] border">No</th>
              <th className="text-left p-2 text-sm font-medium text-[#4b4b4b] border">Booking ID</th>
              <th className="text-left p-2 text-sm font-medium text-[#4b4b4b] border">Player ID</th>
              <th className="text-left p-2 text-sm font-medium text-[#4b4b4b] border">Playtime</th>
              <th className="text-left p-2 text-sm font-medium text-[#4b4b4b] border">Court name</th>
              <th className="text-left p-2 text-sm font-medium text-[#4b4b4b] border">Revenue</th>
            </tr>
          </thead>
          <tbody>
            {filteredBookings.length > 0 ? (
              filteredBookings.map((booking, index) => (
                <tr key={booking.id} className={index % 2 === 1 ? "bg-[#f9f9f9]" : ""}>
                  <td className="p-2 text-sm border">{index + 1}</td>
                  <td className="p-2 text-sm border">{booking.id}</td>
                  <td className="p-2 text-sm border">{booking.playerId}</td>
                  <td className="p-2 text-sm border">{booking.playtime}</td>
                  <td className="p-2 text-sm border">{booking.courtName}</td>
                  <td className="p-2 text-sm border">
                    {new Intl.NumberFormat("vi-VN").format(booking.revenue)} VND
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={6} className="p-4 text-center text-sm text-[#808089]">
                  No bookings found for the selected filters
                </td>
              </tr>
            )}
          </tbody>
          <tfoot>
            <tr className="bg-[#f2f2f2]">
              <td colSpan={5} className="p-2 text-sm font-medium text-right border">
                Total Revenue
              </td>
              <td className="p-2 text-sm font-medium border">
                {new Intl.NumberFormat("vi-VN").format(totalRevenue)} VND
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  );
}
