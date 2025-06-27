"use client"

import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { MapPin, DollarSign } from "lucide-react"
import type { Court } from "@/lib/types"

interface CourtCardProps {
  court: Court
}

export function CourtCard({ court }: CourtCardProps) {
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount)
  }

  return (
    <Card className="bg-white border border-gray-200 hover:shadow-md transition-all duration-200 hover:border-green-300">
      <CardContent className="p-4">
        <div className="space-y-3">
          {/* Header with court name and status */}
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <h4 className="font-semibold text-gray-900 text-lg">Court {court.courtName}</h4>
              {court.state && (
                <Badge variant={court.state === "active" ? "default" : "secondary"} className="mt-1 text-xs">
                  {court.state}
                </Badge>
              )}
            </div>
          </div>

          {/* Description */}
          <div className="space-y-2">
            <p className="text-sm text-gray-600 line-clamp-2 leading-relaxed">
              {court.description || "No description available"}
            </p>
          </div>

          {/* Price section */}
          <div className="flex items-center justify-between pt-2 border-t border-gray-100">
            <div className="flex items-center gap-2">
              <DollarSign className="w-4 h-4 text-green-600" />
              <span className="text-sm text-gray-500">Price per hour</span>
            </div>
            <div className="text-right">
              <span className="text-lg font-bold text-green-600">{formatCurrency(court.pricePerHour)}</span>
            </div>
          </div>

          {/* Booking stats */}
          <div className="flex items-center justify-between pt-2 text-xs text-gray-500">
            <div className="flex items-center gap-1">
              <MapPin className="w-3 h-3" />
              <span>Court ID: {court.id.slice(-8)}</span>
            </div>
            <div>
              {court.orderPeriods.length} booking{court.orderPeriods.length !== 1 ? "s" : ""}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
