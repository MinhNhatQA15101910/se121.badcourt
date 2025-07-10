"use client"

import { FacilityOwnersTable } from "./_components/facility-owners-table"


export default function FacilityOwnerManagementPage() {
  return (
    <div className="min-h-full w-full p-6 overflow-y-auto">
      <div className="grid grid-cols-12 gap-6 overflow-y-auto">
        <div className="col-span-12">
          <FacilityOwnersTable />
        </div>
      </div>
    </div>
  )
}
