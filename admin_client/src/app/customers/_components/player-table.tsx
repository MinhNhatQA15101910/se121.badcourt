"use client"

import type React from "react"
import { useState, useEffect, useCallback } from "react"
import { useRouter } from "next/navigation"
import { ArrowUpDown, ArrowUp, ArrowDown, Filter, MessageCircle } from "lucide-react"
import Image from "next/image"
import { Table, TableBody, TableCell, TableFooter, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Checkbox } from "@/components/ui/checkbox"
import { Button } from "@/components/ui/button"
import { Pagination } from "@/components/ui/pagination"
import { TooltipText } from "@/components/ui/tooltip-text"
import { TooltipProvider } from "@/components/ui/tooltip"
import { Dialog, DialogContent, DialogTitle, DialogTrigger } from "@/components/ui/dialog"
import { userService, type User } from "@/services/userService"
import { FilterValues, PlayerFilter } from "./player-filter"
import { UserDetailModal } from "@/components/user-detail-modal"

export function PlayerTable() {
  const router = useRouter()
  const [sortColumn, setSortColumn] = useState("")
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc")
  const [selectedRows, setSelectedRows] = useState<Record<string, boolean>>({})
  const [selectAll, setSelectAll] = useState(false)
  const [filterOpen, setFilterOpen] = useState(false)
  const [activeFilters, setActiveFilters] = useState<FilterValues>({
    status: "all",
    searchTerm: "",
  })

  // API state
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage, setItemsPerPage] = useState(10)
  const [totalPages, setTotalPages] = useState(0)
  const [totalItems, setTotalItems] = useState(0)

  const [selectedUser, setSelectedUser] = useState<string | null>(null)

  // Fetch users function - using role=player instead of manager
  const fetchUsers = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const params = {
        pageNumber: currentPage,
        pageSize: itemsPerPage,
        role: "player" as const, // Changed from "manager" to "player"
        state: activeFilters.status === "all" ? undefined : (activeFilters.status as "locked" | "active"),
        search: activeFilters.searchTerm || undefined,
      }

      console.log("Fetching players with params:", params)
      const response = await userService.getUsers(params)
      console.log("API Response:", response)

      if (response && typeof response === "object") {
        setUsers(response.items || [])
        setTotalPages(response.totalPages || 0)
        setTotalItems(response.totalCount || 0)

        console.log("Pagination info:", {
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          totalItems: response.totalCount,
          pageSize: response.pageSize,
        })
      } else {
        console.warn("Invalid response:", response)
        setUsers([])
        setTotalPages(0)
        setTotalItems(0)
      }
    } catch (err) {
      console.error("Failed to fetch players:", err)
      setError(`Failed to load players: ${err instanceof Error ? err.message : "Unknown error"}`)
      setUsers([])
      setTotalPages(0)
      setTotalItems(0)
    } finally {
      setLoading(false)
    }
  }, [currentPage, itemsPerPage, activeFilters])

  // Fetch data when filters or pagination changes
  useEffect(() => {
    fetchUsers()
  }, [fetchUsers])

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
      users.forEach((user) => {
        newSelectedRows[user.id] = true
      })
    }
    setSelectedRows(newSelectedRows)
  }

  const handleSelectRow = (userId: string, checked: boolean, event: React.MouseEvent) => {
    event.stopPropagation()

    setSelectedRows((prev) => ({
      ...prev,
      [userId]: checked,
    }))

    const allSelected = Object.keys(selectedRows).length === users.length - 1 && checked
    setSelectAll(allSelected)
  }

  const handleRowClick = (userId: string) => {
    setSelectedUser(userId)
  }

  const handleMessageClick = (userId: string, event: React.MouseEvent) => {
    event.stopPropagation()
    // Navigate to message page or open message modal
    router.push(`/messages/${userId}`)
  }

  const handleApplyFilter = (filters: FilterValues) => {
    setActiveFilters(filters)
    setCurrentPage(1)
  }

  const handlePageChange = (page: number) => {
    setCurrentPage(page)
  }

  const handleItemsPerPageChange = (value: string) => {
    setItemsPerPage(Number(value))
    setCurrentPage(1)
  }

  const getSortIcon = (column: string) => {
    if (sortColumn !== column) return <ArrowUpDown className="ml-2 h-4 w-4" />
    return sortDirection === "asc" ? <ArrowUp className="ml-2 h-4 w-4" /> : <ArrowDown className="ml-2 h-4 w-4" />
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    })
  }

  const selectedCount = Object.values(selectedRows).filter(Boolean).length

  const hasActiveFilters = activeFilters.status !== "all" || activeFilters.searchTerm !== ""

  const handleUserUpdate = useCallback((userId: string, newState: "Active" | "Locked") => {
    console.log("Updating player state:", userId, newState)

    setUsers((prevUsers) => prevUsers.map((user) => (user.id === userId ? { ...user, state: newState } : user)))
  }, [])

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64 bg-white">
        <div className="text-center bg-white p-8 rounded-lg">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Loading players...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64 bg-white">
        <div className="text-center bg-white p-8 rounded-lg">
          <p className="text-red-600 mb-4">{error}</p>
          <Button onClick={fetchUsers} variant="outline" className="bg-white border border-gray-300">
            Try Again
          </Button>
        </div>
      </div>
    )
  }

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
                  <TableHead className="cursor-pointer" onClick={() => handleSort("username")}>
                    <div className="flex items-center">
                      Username
                      {getSortIcon("username")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("email")}>
                    <div className="flex items-center">
                      Email
                      {getSortIcon("email")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("createdAt")}>
                    <div className="flex items-center">
                      Created At
                      {getSortIcon("createdAt")}
                    </div>
                  </TableHead>
                  <TableHead className="cursor-pointer" onClick={() => handleSort("state")}>
                    <div className="flex items-center">
                      State
                      {getSortIcon("state")}
                    </div>
                  </TableHead>
                  <TableHead>Actions</TableHead>
                  <TableHead className="w-[100px] rounded-tr-xl">
                    <div className="flex items-center cursor-pointer" onClick={handleSelectAll}>
                      {selectAll ? "Unselect All" : "Select All"}
                    </div>
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {users && users.length > 0 ? (
                  users.map((user, index) => (
                    <TableRow
                      key={user.id}
                      className={`${
                        selectedRows[user.id] ? "bg-green-50" : ""
                      } hover:bg-muted/20 transition-colors cursor-pointer`}
                      onClick={() => handleRowClick(user.id)}
                    >
                      <TableCell className="font-medium">{(currentPage - 1) * itemsPerPage + index + 1}</TableCell>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          <div className="h-10 w-10 rounded-full overflow-hidden shadow-sm border flex-shrink-0">
                            <Image
                              src={user.photoUrl || "/placeholder.svg?height=40&width=40"}
                              alt={user.username}
                              width={40}
                              height={40}
                              className="object-cover"
                            />
                          </div>
                          <div className="font-medium text-gray-900 max-w-[200px]">
                            <TooltipText text={user.username} maxLength={25} />
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="max-w-[250px]">
                          <TooltipText text={user.email} maxLength={30} />
                        </div>
                      </TableCell>
                      <TableCell>{formatDate(user.createdAt)}</TableCell>
                      <TableCell>
                        <span
                          className={`px-3 py-1 rounded-full text-xs font-medium ${
                            user.state === "Active" ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800"
                          }`}
                        >
                          {user.state}
                        </span>
                      </TableCell>
                      <TableCell>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={(e) => handleMessageClick(user.id, e)}
                          className="h-8 w-8 p-0 bg-[#D7FAE0] hover:bg-[#D7FAE0]/80"
                        >
                          <MessageCircle className="h-4 w-4 text-[#23C16B]" />
                        </Button>
                      </TableCell>
                      <TableCell
                        className="text-center"
                        onClick={(e) => {
                          e.stopPropagation()
                        }}
                      >
                        <Checkbox
                          checked={selectedRows[user.id] || false}
                          onCheckedChange={(checked) => {
                            const syntheticEvent = {
                              stopPropagation: () => {},
                            } as React.MouseEvent
                            handleSelectRow(user.id, checked as boolean, syntheticEvent)
                          }}
                          aria-label={`Select ${user.username}`}
                          className="data-[state=checked]:bg-green-600 data-[state=checked]:border-green-600"
                        />
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={7} className="text-center py-8 text-gray-500">
                      <div className="flex flex-col items-center gap-2">
                        <p>No players found</p>
                        <p className="text-sm text-gray-400">
                          {hasActiveFilters ? "Try adjusting your filters" : "No data available"}
                        </p>
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell colSpan={7} className="rounded-b-xl p-0">
                    <Pagination
                      currentPage={currentPage}
                      totalPages={totalPages}
                      totalItems={totalItems}
                      itemsPerPage={itemsPerPage}
                      startIndex={(currentPage - 1) * itemsPerPage}
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
      {selectedUser && (
        <UserDetailModal
          userId={selectedUser}
          open={!!selectedUser}
          onOpenChange={(open) => {
            if (!open) setSelectedUser(null)
          }}
          onUserUpdate={handleUserUpdate}
        />
      )}
    </TooltipProvider>
  )
}
