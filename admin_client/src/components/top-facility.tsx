"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"

export function TopFacility() {
  return (
    <Card className="shadow-sm h-full">
      <CardHeader className="pb-2">
        <CardTitle className="text-[#425166]">Top Facility</CardTitle>
      </CardHeader>
      <CardContent className="p-0">
        <div className="max-h-[350px] overflow-y-auto px-6 pb-6">
          <table className="w-full">
            <thead className="sticky top-0 bg-white z-10">
              <tr className="text-[#737791] text-sm">
                <th className="font-normal text-left pb-2 pt-2">#</th>
                <th className="font-normal text-left pb-2 pt-2">Name</th>
                <th className="font-normal text-left pb-2 pt-2">Popularity</th>
                <th className="font-normal text-right pb-2 pt-2">Revenue</th>
              </tr>
            </thead>
            <tbody>
              <FacilityRow id="01" name="Sân cầu lông?" progress={85} color="#4079ed" percentage="45%" />
              <FacilityRow id="02" name="Trần Não" progress={65} color="#23c16b" percentage="29%" />
              <FacilityRow id="03" name="Sân cầu lông xịn" progress={40} color="#bf83ff" percentage="18%" />
              <FacilityRow id="04" name="Sân cầu lông siêu xịn" progress={55} color="#ff8900" percentage="25%" />
              <FacilityRow id="05" name="Sân cầu lông Quận 1" progress={35} color="#fa5a7d" percentage="15%" />
              <FacilityRow id="06" name="Sân cầu lông Quận 2" progress={30} color="#00bcd4" percentage="12%" />
              <FacilityRow id="07" name="Sân cầu lông Quận 3" progress={25} color="#ff5722" percentage="10%" />
              <FacilityRow id="08" name="Sân cầu lông Quận 4" progress={20} color="#9c27b0" percentage="8%" />
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  )
}

interface FacilityRowProps {
  id: string
  name: string
  progress: number
  color: string
  percentage: string
}

function FacilityRow({ id, name, progress, color, percentage }: FacilityRowProps) {
  return (
    <tr className="border-b border-gray-100 last:border-0 transition-all hover:bg-gray-50">
      <td className="py-3 text-[#425166]">{id}</td>
      <td className="py-3 text-[#425166]">{name}</td>
      <td className="py-3 w-1/3">
      <Progress value={progress} className="h-2" style={{ backgroundColor: color }} />
      </td>
      <td className="py-3 text-right">
        <span
          className="inline-block px-3 py-1 rounded-full text-xs font-medium"
          style={{ backgroundColor: `${color}20`, color: color }}
        >
          {percentage}
        </span>
      </td>
    </tr>
  )
}

