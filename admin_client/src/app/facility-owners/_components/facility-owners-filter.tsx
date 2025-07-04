"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"

interface FacilityOwnersFilterProps {
  onClose: () => void
  onApplyFilter: (filters: FilterValues) => void
}

export interface FilterValues {
  status: string
  searchTerm: string
}

export function FacilityOwnersFilter({ onClose, onApplyFilter }: FacilityOwnersFilterProps) {
  const [status, setStatus] = useState("all")

  const handleApplyFilter = () => {
    onApplyFilter({
      status,
      searchTerm: "", // We're not using search anymore, but keeping the interface consistent
    })
    onClose()
  }

  const handleReset = () => {
    setStatus("all")
  }

  return (
    <div className="bg-white">
      <div className="space-y-6">
        {/* Status Filter */}
        <div className="space-y-2">
          <Label>Status</Label>
          <RadioGroup value={status} onValueChange={setStatus} className="grid grid-cols-2 gap-2">
            <div className="flex items-center space-x-2">
              <RadioGroupItem value="all" id="all" className="border-green data-[state=checked]:text-green" />
              <Label htmlFor="all" className="cursor-pointer">
                All
              </Label>
            </div>
            <div className="flex items-center space-x-2">
              <RadioGroupItem value="active" id="active" className="border-green data-[state=checked]:text-green" />
              <Label htmlFor="active" className="cursor-pointer">
                Active
              </Label>
            </div>
            <div className="flex items-center space-x-2">
              <RadioGroupItem value="locked" id="locked" className="border-green data-[state=checked]:text-green" />
              <Label htmlFor="locked" className="cursor-pointer">
                Locked
              </Label>
            </div>
          </RadioGroup>
        </div>

        <div className="flex justify-end space-x-2 pt-4">
          <Button variant="outline" onClick={handleReset}>
            Reset
          </Button>
          <Button className="bg-green-600 hover:bg-green-700" onClick={handleApplyFilter}>
            Apply Filters
          </Button>
        </div>
      </div>
    </div>
  )
}
