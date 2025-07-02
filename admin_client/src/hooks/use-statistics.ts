"use client"

import { useState, useEffect } from "react"
import { statisticService } from "@/services/statisticService"

export function useStatistics() {
  const [stats, setStats] = useState({
    revenue: 0,
    players: 0,
    managers: 0,
    orders: 0,
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const loadCurrentTotals = async () => {
    try {
      setLoading(true)
      setError(null)

      const [revenue, players, managers, orders] = await statisticService.getCurrentTotals()
      setStats({ revenue, players, managers, orders })
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load statistics")
      console.error("Error loading statistics:", err)
    } finally {
      setLoading(false)
    }
  }

  const getDateRangeStats = async (startDate: string, endDate: string) => {
    try {
      setLoading(true)
      const [revenue, players, managers, orders] = await statisticService.getDateRangeStats(startDate, endDate)
      setStats({ revenue, players, managers, orders })
      return { revenue, players, managers, orders }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to get date range stats")
      throw err
    } finally {
      setLoading(false)
    }
  }

  const refreshData = () => {
    loadCurrentTotals()
  }

  useEffect(() => {
    loadCurrentTotals()
  }, [])

  return {
    stats,
    loading,
    error,
    refreshData,
    getDateRangeStats,
  }
}
