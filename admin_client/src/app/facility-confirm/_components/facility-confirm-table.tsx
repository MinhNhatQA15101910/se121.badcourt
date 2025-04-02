"use client"

import type React from "react"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { ArrowUpDown, ArrowUp, ArrowDown, Filter } from "lucide-react"
import Image from "next/image"
import { Table, TableBody, TableCell, TableFooter, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Checkbox } from "@/components/ui/checkbox"
import { Button } from "@/components/ui/button"
import { Pagination } from "@/components/ui/pagination"
import { TooltipText } from "@/components/ui/tooltip-text"
import { TooltipProvider } from "@/components/ui/tooltip"
import { Dialog, DialogContent, DialogTitle, DialogTrigger } from "@/components/ui/dialog"
import { FacilityConfirmFilter, type FilterValues } from "@/app/facility-confirm/_components/facility-confirm-filter"
import { FacilityDetails } from "./facility-detail"

const facilities = [
  {
    id: 1,
    facilityName: "Central Hospital",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "123 Main St, New York, NY 10001, United States of America - Medical District Area",
    facilityId: "FAC001",
    ownerName: "John Smith",
    ownerEmail: "john.smith@example.com",
    registerDate: "2023-01-15",
    status: "Active",
    province: "p1",
    district: "d1",
  },
  {
    id: 2,
    facilityName: "Westside Clinic",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "456 West Ave, Los Angeles, CA 90001",
    facilityId: "FAC002",
    ownerName: "Sarah Johnson",
    ownerEmail: "sarah.j@example.com",
    registerDate: "2023-02-20",
    status: "Pending",
    province: "p2",
    district: "d6",
  },
  {
    id: 3,
    facilityName: "Eastside Medical Center",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "789 East Blvd, Chicago, IL 60007",
    facilityId: "FAC003",
    ownerName: "Robert Williams",
    ownerEmail: "r.williams@example.com",
    registerDate: "2022-11-05",
    status: "Active",
    province: "p5",
    district: "d18",
  },
  {
    id: 4,
    facilityName: "North Health Services",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "321 North Rd, Boston, MA 02108",
    facilityId: "FAC004",
    ownerName: "Emily Davis",
    ownerEmail: "emily.d@example.com",
    registerDate: "2023-03-10",
    status: "Inactive",
    province: "p1",
    district: "d2",
  },
  {
    id: 5,
    facilityName: "South Community Hospital",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "654 South St, Miami, FL 33101",
    facilityId: "FAC005",
    ownerName: "Michael Brown",
    ownerEmail: "m.brown@example.com",
    registerDate: "2022-09-18",
    status: "Active",
    province: "p4",
    district: "d14",
  },
  {
    id: 6,
    facilityName: "Downtown Medical Plaza",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "987 Downtown Ave, Seattle, WA 98101",
    facilityId: "FAC006",
    ownerName: "Jennifer Wilson",
    ownerEmail: "j.wilson@example.com",
    registerDate: "2023-04-22",
    status: "Pending",
    province: "p2",
    district: "d7",
  },
  {
    id: 7,
    facilityName: "Riverside Health Center",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "159 Riverside Dr, Austin, TX 78701",
    facilityId: "FAC007",
    ownerName: "David Miller",
    ownerEmail: "david.m@example.com",
    registerDate: "2022-12-30",
    status: "Active",
    province: "p3",
    district: "d11",
  },
  {
    id: 8,
    facilityName: "Mountain View Hospital",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "753 Mountain Rd, Denver, CO 80202",
    facilityId: "FAC008",
    ownerName: "Lisa Taylor",
    ownerEmail: "lisa.t@example.com",
    registerDate: "2023-05-15",
    status: "Active",
    province: "p3",
    district: "d12",
  },
  {
    id: 9,
    facilityName: "Oceanside Medical Group",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "426 Ocean Dr, San Diego, CA 92101",
    facilityId: "FAC009",
    ownerName: "Thomas Anderson",
    ownerEmail: "t.anderson@example.com",
    registerDate: "2023-01-28",
    status: "Inactive",
    province: "p2",
    district: "d8",
  },
  {
    id: 10,
    facilityName: "Valley Care Center",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "871 Valley Blvd, Phoenix, AZ 85001",
    facilityId: "FAC010",
    ownerName: "Amanda Martinez",
    ownerEmail: "a.martinez@example.com",
    registerDate: "2022-10-12",
    status: "Active",
    province: "p3",
    district: "d10",
  },
  {
    id: 11,
    facilityName: "Lakeside Wellness Clinic",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "329 Lake St, Chicago, IL 60007",
    facilityId: "FAC011",
    ownerName: "Kevin Johnson",
    ownerEmail: "k.johnson@example.com",
    registerDate: "2023-06-05",
    status: "Pending",
    province: "p5",
    district: "d18",
  },
  {
    id: 12,
    facilityName: "Parkview Medical Center",
    facilityImage: "/placeholder.svg?height=40&width=40",
    facilityAddress: "512 Park Ave, Atlanta, GA 30301",
    facilityId: "FAC012",
    ownerName: "Nicole White",
    ownerEmail: "n.white@example.com",
    registerDate: "2022-08-22",
    status: "Active",
    province: "p4",
    district: "d15",
  },
]

export function FacilityConfirmTable() {
  const [sortColumn, setSortColumn] = useState("")
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc")
  const [selectedRows, setSelectedRows] = useState<Record<string, boolean>>({})
  const [selectAll, setSelectAll] = useState(false)
  const [filterOpen, setFilterOpen] = useState(false)
  const [activeFilters, setActiveFilters] = useState<FilterValues>({
    province: "all",
    district: "all",
    status: "all",
    searchTerm: "",
  })
  const [selectedFacility, setSelectedFacility] = useState<string | null>(null)

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage, setItemsPerPage] = useState(10)

  const handleSort = (column: string) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc")
    } else {
      setSortColumn(column)
      setSortDirection("asc")
    }
  }

  const handleSelectAll = () => {
    const newSelectAll = !selectAll
    setSelectAll(newSelectAll)

    const newSelectedRows: Record<string, boolean> = {}
    if (newSelectAll) {
      paginatedFacilities.forEach((facility) => {
        newSelectedRows[facility.facilityId] = true
      })
    }
    setSelectedRows(newSelectedRows)
  }

  const handleSelectRow = (facilityId: string, checked: boolean, event: React.MouseEvent) => {
    // Stop propagation to prevent row click navigation when clicking checkbox
    event.stopPropagation()

    setSelectedRows((prev) => ({
      ...prev,
      [facilityId]: checked,
    }))

    // Update selectAll state based on whether all rows are selected
    const allSelected = Object.keys(selectedRows).length === paginatedFacilities.length - 1 && checked
    setSelectAll(allSelected)
  }

  const handleRowClick = (facilityId: string) => {
    setSelectedFacility(facilityId)
  }

  const handleApplyFilter = (filters: FilterValues) => {
    setActiveFilters(filters)
    setCurrentPage(1) // Reset to first page when applying filters
  }

  // Apply filters to facilities
  const filteredFacilities = facilities.filter((facility) => {
    // Filter by search term (keeping this for compatibility)
    if (
      activeFilters.searchTerm &&
      !facility.facilityName.toLowerCase().includes(activeFilters.searchTerm.toLowerCase()) &&
      !facility.facilityId.toLowerCase().includes(activeFilters.searchTerm.toLowerCase())
    ) {
      return false
    }

    // Filter by province (skip if empty or "all")
    if (activeFilters.province && activeFilters.province !== "all" && facility.province !== activeFilters.province) {
      return false
    }

    // Filter by district (skip if empty or "all")
    if (activeFilters.district && activeFilters.district !== "all" && facility.district !== activeFilters.district) {
      return false
    }

    // Filter by status (skip if "all")
    if (activeFilters.status !== "all" && facility.status.toLowerCase() !== activeFilters.status) {
      return false
    }

    return true
  })

  const sortedFacilities = [...filteredFacilities].sort((a, b) => {
    if (sortColumn === "") return 0

    const aValue = a[sortColumn as keyof typeof a]
    const bValue = b[sortColumn as keyof typeof a]

    if (sortColumn === "registerDate") {
      // Sort dates
      const aDate = new Date(aValue.toString())
      const bDate = new Date(bValue.toString())
      return sortDirection === "asc" ? aDate.getTime() - bDate.getTime() : bDate.getTime() - aDate.getTime()
    }

    // Sort strings
    if (aValue < bValue) return sortDirection === "asc" ? -1 : 1
    if (aValue > bValue) return sortDirection === "asc" ? 1 : -1
    return 0
  })

  // Calculate pagination
  const totalPages = Math.ceil(sortedFacilities.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const paginatedFacilities = sortedFacilities.slice(startIndex, startIndex + itemsPerPage)

  const handlePageChange = (page: number) => {
    setCurrentPage(page)
  }

  const handleItemsPerPageChange = (value: string) => {
    setItemsPerPage(Number(value))
    setCurrentPage(1) // Reset to first page when changing items per page
  }

  const getSortIcon = (column: string) => {
    if (sortColumn !== column) return <ArrowUpDown className="ml-2 h-4 w-4" />
    return sortDirection === "asc" ? <ArrowUp className="ml-2 h-4 w-4" /> : <ArrowDown className="ml-2 h-4 w-4" />
  }

  // Format date to be more readable
  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    })
  }

  // Count selected rows
  const selectedCount = Object.values(selectedRows).filter(Boolean).length

  // Check if any filters are active
  const hasActiveFilters =
    (activeFilters.province !== "" && activeFilters.province !== "all") ||
    (activeFilters.district !== "" && activeFilters.district !== "all") ||
    activeFilters.status !== "all" ||
    activeFilters.searchTerm !== ""

  return (
    <TooltipProvider>
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <h2 className="text-xl font-semibold text-gray-800">Facility Management</h2>

            <Dialog open={filterOpen} onOpenChange={setFilterOpen}>
              <DialogTrigger asChild>
                <Button
                  variant={hasActiveFilters ? "default" : "outline"}
                  size="sm"
                  className={hasActiveFilters ? "bg-green-600 hover:bg-green-700" : ""}
                >
                  <Filter className="mr-2 h-4 w-4" />
                  {hasActiveFilters ? "Filters Applied" : "Filter"}
                </Button>
              </DialogTrigger>
              <DialogContent className="sm:max-w-[425px] p-4">
                <DialogTitle className="text-2xl text-black-grey">Filter Facilities</DialogTitle>
                <FacilityConfirmFilter onClose={() => setFilterOpen(false)} onApplyFilter={handleApplyFilter} />
              </DialogContent>
            </Dialog>
          </div>

          {selectedCount > 0 && (
            <div className="bg-green-600 text-white px-4 py-2 rounded-full text-sm font-medium">
              {selectedCount} {selectedCount === 1 ? "facility" : "facilities"} selected
            </div>
          )}
        </div>

        <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="bg-muted/30 hover:bg-muted/40">
                  <TableHead className="w-[60px] rounded-tl-xl">No</TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("facilityName")}>
                    <div className="flex items-center">
                      Facility Name
                      {getSortIcon("facilityName")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("facilityId")}>
                    <div className="flex items-center">
                      Facility ID
                      {getSortIcon("facilityId")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("ownerName")}>
                    <div className="flex items-center">
                      Owner Name
                      {getSortIcon("ownerName")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("registerDate")}>
                    <div className="flex items-center">
                      Register Date
                      {getSortIcon("registerDate")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("status")}>
                    <div className="flex items-center">
                      Status
                      {getSortIcon("status")}
                    </div>
                  </TableHead>
                  <TableHead className="w-[100px] rounded-tr-xl">
                    <div className="flex items-center cursor-pointer" onClick={handleSelectAll}>
                      {selectAll ? "Unselect All" : "Select All"}
                    </div>
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {paginatedFacilities.map((facility, index) => (
                  <TableRow
                    key={facility.facilityId}
                    className={`${
                      selectedRows[facility.facilityId] ? "bg-green-50" : ""
                    } hover:bg-muted/20 transition-colors cursor-pointer`}
                    onClick={() => handleRowClick(facility.facilityId)}
                  >
                    <TableCell className="font-medium">{startIndex + index + 1}</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-lg overflow-hidden shadow-sm border">
                          <Image
                            src={facility.facilityImage || "/placeholder.svg"}
                            alt={facility.facilityName}
                            width={40}
                            height={40}
                            className="object-cover"
                          />
                        </div>
                        <div>
                          <div className="font-medium text-gray-900 max-w-[200px]">
                            <TooltipText text={facility.facilityName} maxLength={25} />
                          </div>
                          <div className="text-xs text-muted-foreground max-w-[200px]">
                            <TooltipText text={facility.facilityAddress} maxLength={30} />
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="font-mono text-sm">{facility.facilityId}</TableCell>
                    <TableCell>
                      <div>
                        <div className="font-medium text-gray-900 max-w-[150px]">
                          <TooltipText text={facility.ownerName} maxLength={20} />
                        </div>
                        <div className="text-xs text-muted-foreground max-w-[150px]">
                          <TooltipText text={facility.ownerEmail} maxLength={25} />
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{formatDate(facility.registerDate)}</TableCell>
                    <TableCell>
                      <span
                        className={`px-3 py-1 rounded-full text-xs font-medium ${
                          facility.status === "Active"
                            ? "bg-green-100 text-green-800"
                            : facility.status === "Pending"
                              ? "bg-yellow-100 text-yellow-800"
                              : "bg-red-100 text-red-800"
                        }`}
                      >
                        {facility.status}
                      </span>
                    </TableCell>
                    <TableCell
                      className="text-center"
                      onClick={(e) => {
                        e.stopPropagation()
                      }}
                    >
                      <Checkbox
                        checked={selectedRows[facility.facilityId] || false}
                        onCheckedChange={(checked) => {
                          // Create a synthetic mouse event
                          const syntheticEvent = {
                            stopPropagation: () => {},
                          } as React.MouseEvent
                          handleSelectRow(facility.facilityId, checked as boolean, syntheticEvent)
                        }}
                        aria-label={`Select ${facility.facilityName}`}
                        className="data-[state=checked]:bg-green-600 data-[state=checked]:border-green-600"
                      />
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell colSpan={7} className="rounded-b-xl p-0">
                    <Pagination
                      currentPage={currentPage}
                      totalPages={totalPages}
                      totalItems={filteredFacilities.length}
                      itemsPerPage={itemsPerPage}
                      startIndex={startIndex}
                      onPageChange={handlePageChange}
                      onItemsPerPageChange={handleItemsPerPageChange}
                    />
                  </TableCell>
                </TableRow>
              </TableFooter>
            </Table>
          </div>
        </div>
      </div>
      {selectedFacility && (
        <FacilityDetails
          facilityId={selectedFacility}
          open={!!selectedFacility}
          onOpenChange={(open) => {
            if (!open) setSelectedFacility(null)
          }}
        />
      )}
    </TooltipProvider>
  )
}

