"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { facilityService } from "@/services/facilityService"

interface FacilityConfirmFilterProps {
  onClose: () => void
  onApplyFilter: (filters: FilterValues) => void
}

export interface FilterValues {
  province: string
  status: string
  searchTerm: string
}

export function FacilityConfirmFilter({ onClose, onApplyFilter }: FacilityConfirmFilterProps) {
  const [selectedProvince, setSelectedProvince] = useState("all")
  const [status, setStatus] = useState("all")
  const [provinces, setProvinces] = useState<string[]>([])
  const [loading, setLoading] = useState(true)

  // Fetch provinces from API
  useEffect(() => {
    const fetchProvinces = async () => {
      try {
        setLoading(true)
        const provincesData = await facilityService.getProvinces()
        console.log("Provinces data:", provincesData)

        // Since API returns array of strings, we add "All Provinces" option
        setProvinces(["All Provinces", ...provincesData])
      } catch (error) {
        console.error("Failed to fetch provinces:", error)
        // Fallback to empty array if API fails
        setProvinces(["All Provinces"])
      } finally {
        setLoading(false)
      }
    }

    fetchProvinces()
  }, [])

  const handleApplyFilter = () => {
    onApplyFilter({
      province: selectedProvince,
      status,
      searchTerm: "", // We're not using search in this filter, but keeping for compatibility
    })
    onClose()
  }

  const handleReset = () => {
    setSelectedProvince("all")
    setStatus("all")
  }

  return (
    <div className="bg-white">
      <div className="space-y-6">
        {/* Location Filter */}
        <div className="space-y-4">
          <h4 className="text-sm font-medium">Location</h4>

          <div className="grid grid-cols-1 gap-4">
            <Select value={selectedProvince} onValueChange={setSelectedProvince} disabled={loading}>
              <SelectTrigger id="province" className="w-full h-10">
                <SelectValue placeholder={loading ? "Loading provinces..." : "Select province"} />
              </SelectTrigger>
              <SelectContent>
                {provinces.map((province, index) => (
                  <SelectItem key={index} value={index === 0 ? "all" : province}>
                    {province}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

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
              <RadioGroupItem value="approved" id="approved" className="border-green data-[state=checked]:text-green" />
              <Label htmlFor="approved" className="cursor-pointer">
                Approved
              </Label>
            </div>
            <div className="flex items-center space-x-2">
              <RadioGroupItem value="pending" id="pending" className="border-green data-[state=checked]:text-green" />
              <Label htmlFor="pending" className="cursor-pointer">
                Pending
              </Label>
            </div>
            <div className="flex items-center space-x-2">
              <RadioGroupItem value="rejected" id="rejected" className="border-green data-[state=checked]:text-green" />
              <Label htmlFor="rejected" className="cursor-pointer">
                Rejected
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
