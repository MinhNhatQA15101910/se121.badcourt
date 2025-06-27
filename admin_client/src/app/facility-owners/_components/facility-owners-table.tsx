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
import { FacilityOwnersFilter, type FilterValues } from "./facility-owners-filter"

const owners = [
  {
    id: 1,
    ownerName: "John Smith",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "john.smith@example.com",
    ownerId: "OWN001",
    ownerAddress: "123 Main St, New York, NY 10001, United States of America",
    numberOfFacilities: 3,
    totalRevenue: 325000000,
    status: "Activated",
    province: "p1",
    district: "d1",
  },
  {
    id: 2,
    ownerName: "Sarah Johnson",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "sarah.j@example.com",
    ownerId: "OWN002",
    ownerAddress: "456 West Ave, Los Angeles, CA 90001",
    numberOfFacilities: 1,
    totalRevenue: 87500000,
    status: "Activated",
    province: "p2",
    district: "d6",
  },
  {
    id: 3,
    ownerName: "Robert Williams",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "r.williams@example.com",
    ownerId: "OWN003",
    ownerAddress: "789 East Blvd, Chicago, IL 60007",
    numberOfFacilities: 2,
    totalRevenue: 210000000,
    status: "Deactivated",
    province: "p5",
    district: "d18",
  },
  {
    id: 4,
    ownerName: "Emily Davis",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "emily.d@example.com",
    ownerId: "OWN004",
    ownerAddress: "321 North Rd, Boston, MA 02108",
    numberOfFacilities: 1,
    totalRevenue: 65000000,
    status: "Activated",
    province: "p1",
    district: "d2",
  },
  {
    id: 5,
    ownerName: "Michael Brown",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "m.brown@example.com",
    ownerId: "OWN005",
    ownerAddress: "654 South St, Miami, FL 33101",
    numberOfFacilities: 2,
    totalRevenue: 175000000,
    status: "Activated",
    province: "p4",
    district: "d14",
  },
  {
    id: 6,
    ownerName: "Jennifer Wilson",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "j.wilson@example.com",
    ownerId: "OWN006",
    ownerAddress: "987 Downtown Ave, Seattle, WA 98101",
    numberOfFacilities: 1,
    totalRevenue: 92000000,
    status: "Deactivated",
    province: "p2",
    district: "d7",
  },
  {
    id: 7,
    ownerName: "David Miller",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "david.m@example.com",
    ownerId: "OWN007",
    ownerAddress: "159 Riverside Dr, Austin, TX 78701",
    numberOfFacilities: 1,
    totalRevenue: 145000000,
    status: "Activated",
    province: "p3",
    district: "d11",
  },
  {
    id: 8,
    ownerName: "Lisa Taylor",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "lisa.t@example.com",
    ownerId: "OWN008",
    ownerAddress: "753 Mountain Rd, Denver, CO 80202",
    numberOfFacilities: 1,
    totalRevenue: 195000000,
    status: "Activated",
    province: "p3",
    district: "d12",
  },
  {
    id: 9,
    ownerName: "Thomas Anderson",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "t.anderson@example.com",
    ownerId: "OWN009",
    ownerAddress: "426 Ocean Dr, San Diego, CA 92101",
    numberOfFacilities: 1,
    totalRevenue: 78000000,
    status: "Deactivated",
    province: "p2",
    district: "d8",
  },
  {
    id: 10,
    ownerName: "Amanda Martinez",
    ownerImage: "/placeholder.svg?height=40&width=40",
    ownerEmail: "a.martinez@example.com",
    ownerId: "OWN010",
    ownerAddress: "871 Valley Blvd, Phoenix, AZ 85001",
    numberOfFacilities: 1,
    totalRevenue: 155000000,
    status: "Activated",
    province: "p3",
    district: "d10",
  },
]

export function FacilityOwnersTable() {
  const router = useRouter()
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
      paginatedOwners.forEach((owner) => {
        newSelectedRows[owner.ownerId] = true
      })
    }
    setSelectedRows(newSelectedRows)
  }

  const handleSelectRow = (ownerId: string, checked: boolean, event: React.MouseEvent) => {
    // Stop propagation to prevent row click navigation when clicking checkbox
    event.stopPropagation()

    setSelectedRows((prev) => ({
      ...prev,
      [ownerId]: checked,
    }))

    // Update selectAll state based on whether all rows are selected
    const allSelected = Object.keys(selectedRows).length === paginatedOwners.length - 1 && checked
    setSelectAll(allSelected)
  }

  const handleRowClick = (ownerId: string) => {
    router.push(`/facility-owners-detail/${ownerId}`)
  }

  const handleApplyFilter = (filters: FilterValues) => {
    setActiveFilters(filters)
    setCurrentPage(1) // Reset to first page when applying filters
  }

  // Apply filters to owners
  const filteredOwners = owners.filter((owner) => {
    // Filter by search term (keeping this for compatibility)
    if (
      activeFilters.searchTerm &&
      !owner.ownerName.toLowerCase().includes(activeFilters.searchTerm.toLowerCase()) &&
      !owner.ownerId.toLowerCase().includes(activeFilters.searchTerm.toLowerCase())
    ) {
      return false
    }

    // Filter by province (skip if empty or "all")
    if (activeFilters.province && activeFilters.province !== "all" && owner.province !== activeFilters.province) {
      return false
    }

    // Filter by district (skip if empty or "all")
    if (activeFilters.district && activeFilters.district !== "all" && owner.district !== activeFilters.district) {
      return false
    }

    // Filter by status (skip if "all")
    if (activeFilters.status !== "all" && owner.status.toLowerCase() !== activeFilters.status.toLowerCase()) {
      return false
    }

    return true
  })

  const sortedOwners = [...filteredOwners].sort((a, b) => {
    if (sortColumn === "") return 0

    const aValue = a[sortColumn as keyof typeof a]
    const bValue = b[sortColumn as keyof typeof a]

    if (typeof aValue === "number" && typeof bValue === "number") {
      return sortDirection === "asc" ? aValue - bValue : bValue - aValue
    }

    // Sort strings
    if (aValue < bValue) return sortDirection === "asc" ? -1 : 1
    if (aValue > bValue) return sortDirection === "asc" ? 1 : -1
    return 0
  })

  // Calculate pagination
  const totalPages = Math.ceil(sortedOwners.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const paginatedOwners = sortedOwners.slice(startIndex, startIndex + itemsPerPage)

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

  // Format currency to VND format
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount)
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
            <h2 className="text-xl font-semibold text-gray-800">Facility Owners Management</h2>

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
                <DialogTitle className="text-2xl text-black-grey">Filter Owners</DialogTitle>
                <FacilityOwnersFilter onClose={() => setFilterOpen(false)} onApplyFilter={handleApplyFilter} />
              </DialogContent>
            </Dialog>
          </div>

          {selectedCount > 0 && (
            <div className="bg-green-600 text-white px-4 py-2 rounded-full text-sm font-medium">
              {selectedCount} {selectedCount === 1 ? "owner" : "owners"} selected
            </div>
          )}
        </div>

        <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="bg-muted/30 hover:bg-muted/40">
                  <TableHead className="w-[60px] rounded-tl-xl">No</TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("ownerName")}>
                    <div className="flex items-center">
                      Owner Name
                      {getSortIcon("ownerName")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("ownerId")}>
                    <div className="flex items-center">
                      Owner ID
                      {getSortIcon("ownerId")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("ownerAddress")}>
                    <div className="flex items-center">
                      Owner Address
                      {getSortIcon("ownerAddress")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("numberOfFacilities")}>
                    <div className="flex items-center">
                      Number of Facilities
                      {getSortIcon("numberOfFacilities")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("totalRevenue")}>
                    <div className="flex items-center">
                      Total Revenue
                      {getSortIcon("totalRevenue")}
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
                {paginatedOwners.map((owner, index) => (
                  <TableRow
                    key={owner.ownerId}
                    className={`${
                      selectedRows[owner.ownerId] ? "bg-green-50" : ""
                    } hover:bg-muted/20 transition-colors cursor-pointer`}
                    onClick={() => handleRowClick(owner.ownerId)}
                  >
                    <TableCell className="font-medium">{startIndex + index + 1}</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full overflow-hidden shadow-sm border">
                          <Image
                            src={owner.ownerImage || "/placeholder.svg"}
                            alt={owner.ownerName}
                            width={40}
                            height={40}
                            className="object-cover"
                          />
                        </div>
                        <div>
                          <div className="font-medium text-gray-900 max-w-[200px]">
                            <TooltipText text={owner.ownerName} maxLength={25} />
                          </div>
                          <div className="text-xs text-muted-foreground max-w-[200px]">
                            <TooltipText text={owner.ownerEmail} maxLength={30} />
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="font-mono text-sm">{owner.ownerId}</TableCell>
                    <TableCell>
                      <div className="max-w-[200px]">
                        <TooltipText text={owner.ownerAddress} maxLength={30} />
                      </div>
                    </TableCell>
                    <TableCell className="text-center">{owner.numberOfFacilities}</TableCell>
                    <TableCell className="font-medium text-left">{formatCurrency(owner.totalRevenue)}</TableCell>
                    <TableCell>
                      <span
                        className={`px-3 py-1 rounded-full text-xs font-medium ${
                          owner.status === "Activated" ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800"
                        }`}
                      >
                        {owner.status}
                      </span>
                    </TableCell>
                    <TableCell
                      className="text-center"
                      onClick={(e) => {
                        e.stopPropagation()
                      }}
                    >
                      <Checkbox
                        checked={selectedRows[owner.ownerId] || false}
                        onCheckedChange={(checked) => {
                          // Create a synthetic mouse event
                          const syntheticEvent = {
                            stopPropagation: () => {},
                          } as React.MouseEvent
                          handleSelectRow(owner.ownerId, checked as boolean, syntheticEvent)
                        }}
                        aria-label={`Select ${owner.ownerName}`}
                        className="data-[state=checked]:bg-green-600 data-[state=checked]:border-green-600"
                      />
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell colSpan={8} className="rounded-b-xl p-0">
                    <Pagination
                      currentPage={currentPage}
                      totalPages={totalPages}
                      totalItems={filteredOwners.length}
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
    </TooltipProvider>
  )
}

