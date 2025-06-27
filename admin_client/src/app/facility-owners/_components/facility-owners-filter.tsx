"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"

// Mock data for provinces and districts
const provinces = [
  { id: "all", name: "All Provinces" },
  { id: "p1", name: "New York" },
  { id: "p2", name: "California" },
  { id: "p3", name: "Texas" },
  { id: "p4", name: "Florida" },
  { id: "p5", name: "Illinois" },
]

// Districts by province
const districtsByProvince: Record<string, { id: string; name: string }[]> = {
  p1: [
    { id: "all", name: "All Districts" },
    { id: "d1", name: "Manhattan" },
    { id: "d2", name: "Brooklyn" },
    { id: "d3", name: "Queens" },
    { id: "d4", name: "Bronx" },
    { id: "d5", name: "Staten Island" },
  ],
  p2: [
    { id: "all", name: "All Districts" },
    { id: "d6", name: "Los Angeles" },
    { id: "d7", name: "San Francisco" },
    { id: "d8", name: "San Diego" },
    { id: "d9", name: "Sacramento" },
  ],
  p3: [
    { id: "all", name: "All Districts" },
    { id: "d10", name: "Houston" },
    { id: "d11", name: "Austin" },
    { id: "d12", name: "Dallas" },
    { id: "d13", name: "San Antonio" },
  ],
  p4: [
    { id: "all", name: "All Districts" },
    { id: "d14", name: "Miami" },
    { id: "d15", name: "Orlando" },
    { id: "d16", name: "Tampa" },
    { id: "d17", name: "Jacksonville" },
  ],
  p5: [
    { id: "all", name: "All Districts" },
    { id: "d18", name: "Chicago" },
    { id: "d19", name: "Springfield" },
    { id: "d20", name: "Peoria" },
  ],
}

interface FacilityOwnersFilterProps {
  onClose: () => void
  onApplyFilter: (filters: FilterValues) => void
}

export interface FilterValues {
  province: string
  district: string
  status: string
  searchTerm: string
}

export function FacilityOwnersFilter({ onClose, onApplyFilter }: FacilityOwnersFilterProps) {
  const [selectedProvince, setSelectedProvince] = useState("all")
  const [selectedDistrict, setSelectedDistrict] = useState("all")
  const [status, setStatus] = useState("all")
  const [availableDistricts, setAvailableDistricts] = useState<{ id: string; name: string }[]>([])

  // Update districts when province changes
  useState(() => {
    if (selectedProvince === "all") {
      setSelectedDistrict("all")
      setAvailableDistricts([{ id: "all", name: "All Districts" }])
    } else if (selectedProvince) {
      setAvailableDistricts(districtsByProvince[selectedProvince] || [])
    } else {
      setAvailableDistricts([])
      setSelectedDistrict("all")
    }
  })

  const handleApplyFilter = () => {
    onApplyFilter({
      province: selectedProvince,
      district: selectedDistrict,
      status,
      searchTerm: "", // We're not using search anymore, but keeping the interface consistent
    })
    onClose()
  }

  const handleReset = () => {
    setSelectedProvince("all")
    setSelectedDistrict("all")
    setStatus("all")
  }

  return (
    <div className="bg-white">
      <div className="space-y-6">
        {/* Location Filter */}
        <div className="space-y-4">
          <h4 className="text-sm font-medium">Location</h4>

          <div className="grid grid-cols-2 gap-4">
            <Select value={selectedProvince} onValueChange={setSelectedProvince}>
              <SelectTrigger id="province" className="w-full h-10">
                <SelectValue placeholder="Select province" />
              </SelectTrigger>
              <SelectContent>
                {provinces.map((province) => (
                  <SelectItem key={province.id} value={province.id}>
                    {province.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            <Select value={selectedDistrict} onValueChange={setSelectedDistrict} disabled={selectedProvince === "all"}>
              <SelectTrigger id="district" className="w-full h-10">
                <SelectValue placeholder={selectedProvince === "all" ? "All Districts" : "Select district"} />
              </SelectTrigger>
              <SelectContent>
                {availableDistricts.map((district) => (
                  <SelectItem key={district.id} value={district.id}>
                    {district.name}
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
              <RadioGroupItem value="all" id="all" className=" border-green  data-[state=checked]:text-green" />
              <Label htmlFor="all" className="cursor-pointer">
                All
              </Label>
            </div>
            <div className="flex items-center space-x-2">
              <RadioGroupItem
                value="activated"
                id="activated"
                className="border-green  data-[state=checked]:text-green"
              />
              <Label htmlFor="activated" className="cursor-pointer">
                Activated
              </Label>
            </div>
            <div className="flex items-center space-x-2">
              <RadioGroupItem
                value="deactivated"
                id="deactivated"
                className="border-green  data-[state=checked]:text-green"
              />
              <Label htmlFor="deactivated" className="cursor-pointer">
                Deactivated
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

