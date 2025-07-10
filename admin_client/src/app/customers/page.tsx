"use client"

import { PlayerTable } from "./_components/player-table"


export default function PlayerManagementPage() {
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
