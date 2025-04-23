"use client"

import { useState, useEffect } from "react"
import { PlayerTable } from "./_components/player-table"

export default function PlayerPage() {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return null
  }

  return (
    <div className="min-h-full w-full p-6 overflow-y-auto">
      <div className="grid grid-cols-12 gap-6 overflow-y-auto">
        <div className="col-span-12">
          <PlayerTable />
        </div>
      </div>
    </div>
  )
}

