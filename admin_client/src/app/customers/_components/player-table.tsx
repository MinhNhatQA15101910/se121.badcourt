"use client";

import type React from "react";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowUpDown, ArrowUp, ArrowDown, Filter } from 'lucide-react';
import Image from "next/image";
import { Table, TableBody, TableCell, TableFooter, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";
import {
  Pagination,
} from "@/components/ui/pagination";
import { TooltipText } from "@/components/ui/tooltip-text";
import { TooltipProvider } from "@/components/ui/tooltip";
import { Dialog, DialogContent, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { PlayerFilter, type FilterValues } from "./player-filter";

// Mock data for players
const players = [
  {
    id: 1,
    playerName: "Alex Johnson",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "alex.j@example.com",
    playerId: "PLY001",
    createDate: "2023-01-15",
    lastActivity: "2023-06-20",
    totalBooking: 12,
    totalSpend: 3500000,
    status: "Active",
    province: "p1",
    district: "d1",
  },
  {
    id: 2,
    playerName: "Maria Garcia",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "maria.g@example.com",
    playerId: "PLY002",
    createDate: "2023-02-05",
    lastActivity: "2023-06-18",
    totalBooking: 8,
    totalSpend: 2100000,
    status: "Active",
    province: "p2",
    district: "d6",
  },
  {
    id: 3,
    playerName: "James Wilson",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "james.w@example.com",
    playerId: "PLY003",
    createDate: "2023-02-10",
    lastActivity: "2023-05-30",
    totalBooking: 5,
    totalSpend: 1250000,
    status: "Inactive",
    province: "p5",
    district: "d18",
  },
  {
    id: 4,
    playerName: "Sophie Chen",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "sophie.c@example.com",
    playerId: "PLY004",
    createDate: "2023-03-01",
    lastActivity: "2023-06-15",
    totalBooking: 15,
    totalSpend: 4200000,
    status: "Active",
    province: "p1",
    district: "d2",
  },
  {
    id: 5,
    playerName: "David Kim",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "david.k@example.com",
    playerId: "PLY005",
    createDate: "2023-03-15",
    lastActivity: "2023-06-10",
    totalBooking: 7,
    totalSpend: 1850000,
    status: "Active",
    province: "p4",
    district: "d14",
  },
  {
    id: 6,
    playerName: "Emma Thompson",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "emma.t@example.com",
    playerId: "PLY006",
    createDate: "2023-04-02",
    lastActivity: "2023-05-25",
    totalBooking: 3,
    totalSpend: 750000,
    status: "Inactive",
    province: "p2",
    district: "d7",
  },
  {
    id: 7,
    playerName: "Michael Brown",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "michael.b@example.com",
    playerId: "PLY007",
    createDate: "2023-04-10",
    lastActivity: "2023-06-19",
    totalBooking: 10,
    totalSpend: 2800000,
    status: "Active",
    province: "p3",
    district: "d11",
  },
  {
    id: 8,
    playerName: "Olivia Davis",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "olivia.d@example.com",
    playerId: "PLY008",
    createDate: "2023-04-25",
    lastActivity: "2023-06-17",
    totalBooking: 9,
    totalSpend: 2350000,
    status: "Active",
    province: "p3",
    district: "d12",
  },
  {
    id: 9,
    playerName: "Daniel Martinez",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "daniel.m@example.com",
    playerId: "PLY009",
    createDate: "2023-05-05",
    lastActivity: "2023-06-01",
    totalBooking: 2,
    totalSpend: 500000,
    status: "Inactive",
    province: "p2",
    district: "d8",
  },
  {
    id: 10,
    playerName: "Sophia Rodriguez",
    playerImage: "/placeholder.svg?height=40&width=40",
    playerEmail: "sophia.r@example.com",
    playerId: "PLY010",
    createDate: "2023-05-20",
    lastActivity: "2023-06-16",
    totalBooking: 6,
    totalSpend: 1650000,
    status: "Active",
    province: "p3",
    district: "d10",
  },
]

export function PlayerTable() {
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
      paginatedPlayers.forEach((player) => {
        newSelectedRows[player.playerId] = true
      })
    }
    setSelectedRows(newSelectedRows)
  }

  const handleSelectRow = (playerId: string, checked: boolean, event: React.MouseEvent) => {
    // Stop propagation to prevent row click navigation when clicking checkbox
    event.stopPropagation()

    setSelectedRows((prev) => ({
      ...prev,
      [playerId]: checked,
    }))

    // Update selectAll state based on whether all rows are selected
    const allSelected = Object.keys(selectedRows).length === paginatedPlayers.length - 1 && checked
    setSelectAll(allSelected)
  }

  const handleRowClick = (playerId: string) => {
    router.push(`/player-detail/${playerId}`)
  }

  const handleApplyFilter = (filters: FilterValues) => {
    setActiveFilters(filters)
    setCurrentPage(1) // Reset to first page when applying filters
  }

  // Apply filters to players
  const filteredPlayers = players.filter((player) => {
    // Filter by search term (keeping this for compatibility)
    if (
      activeFilters.searchTerm &&
      !player.playerName.toLowerCase().includes(activeFilters.searchTerm.toLowerCase()) &&
      !player.playerId.toLowerCase().includes(activeFilters.searchTerm.toLowerCase())
    ) {
      return false
    }

    // Filter by province (skip if empty or "all")
    if (activeFilters.province && activeFilters.province !== "all" && player.province !== activeFilters.province) {
      return false
    }

    // Filter by district (skip if empty or "all")
    if (activeFilters.district && activeFilters.district !== "all" && player.district !== activeFilters.district) {
      return false
    }

    // Filter by status (skip if "all")
    if (activeFilters.status !== "all" && player.status.toLowerCase() !== activeFilters.status.toLowerCase()) {
      return false
    }

    return true
  })

  const sortedPlayers = [...filteredPlayers].sort((a, b) => {
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
  const totalPages = Math.ceil(sortedPlayers.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const paginatedPlayers = sortedPlayers.slice(startIndex, startIndex + itemsPerPage)

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

  // Format date to display format
  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return new Intl.DateTimeFormat("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    }).format(date)
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
            <h2 className="text-xl font-semibold text-gray-800">Player Management</h2>

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
                <DialogTitle className="text-2xl text-black-grey">Filter Players</DialogTitle>
                <PlayerFilter onClose={() => setFilterOpen(false)} onApplyFilter={handleApplyFilter} />
              </DialogContent>
            </Dialog>
          </div>

          {selectedCount > 0 && (
            <div className="bg-green-600 text-white px-4 py-2 rounded-full text-sm font-medium">
              {selectedCount} {selectedCount === 1 ? "player" : "players"} selected
            </div>
          )}
        </div>

        <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="bg-muted/30 hover:bg-muted/40">
                  <TableHead className="w-[60px] rounded-tl-xl">No</TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("playerName")}>
                    <div className="flex items-center">
                      Player Name
                      {getSortIcon("playerName")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("createDate")}>
                    <div className="flex items-center">
                      Create Date
                      {getSortIcon("createDate")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("lastActivity")}>
                    <div className="flex items-center">
                      Last Activity
                      {getSortIcon("lastActivity")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("totalBooking")}>
                    <div className="flex items-center">
                      Total Booking
                      {getSortIcon("totalBooking")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("totalSpend")}>
                    <div className="flex items-center">
                      Total Spend
                      {getSortIcon("totalSpend")}
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
                {paginatedPlayers.map((player, index) => (
                  <TableRow
                    key={player.playerId}
                    className={`${
                      selectedRows[player.playerId] ? "bg-green-50" : ""
                    } hover:bg-muted/20 transition-colors cursor-pointer`}
                    onClick={() => handleRowClick(player.playerId)}
                  >
                    <TableCell className="font-medium">{startIndex + index + 1}</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full overflow-hidden shadow-sm border">
                          <Image
                            src={player.playerImage || "/placeholder.svg"}
                            alt={player.playerName}
                            width={40}
                            height={40}
                            className="object-cover"
                          />
                        </div>
                        <div>
                          <div className="font-medium text-gray-900 max-w-[200px]">
                            <TooltipText text={player.playerName} maxLength={25} />
                          </div>
                          <div className="text-xs text-muted-foreground max-w-[200px]">
                            <TooltipText text={player.playerEmail} maxLength={30} />
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{formatDate(player.createDate)}</TableCell>
                    <TableCell>{formatDate(player.lastActivity)}</TableCell>
                    <TableCell className="text-center">{player.totalBooking}</TableCell>
                    <TableCell className="font-medium text-left">{formatCurrency(player.totalSpend)}</TableCell>
                    <TableCell>
                      <span
                        className={`px-3 py-1 rounded-full text-xs font-medium ${
                          player.status === "Active" ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800"
                        }`}
                      >
                        {player.status}
                      </span>
                    </TableCell>
                    <TableCell
                      className="text-center"
                      onClick={(e) => {
                        e.stopPropagation()
                      }}
                    >
                      <Checkbox
                        checked={selectedRows[player.playerId] || false}
                        onCheckedChange={(checked) => {
                          // Create a synthetic mouse event
                          const syntheticEvent = {
                            stopPropagation: () => {},
                          } as React.MouseEvent
                          handleSelectRow(player.playerId, checked as boolean, syntheticEvent)
                        }}
                        aria-label={`Select ${player.playerName}`}
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
                      totalItems={filteredPlayers.length}
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
