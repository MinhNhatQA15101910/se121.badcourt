"use client";

import type React from "react";
import { useState, useEffect, useCallback } from "react";
import { useSearchParams } from "next/navigation";
import { ArrowUpDown, ArrowUp, ArrowDown, Filter, Star } from "lucide-react";
import Image from "next/image";
import {
  Table,
  TableBody,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";
import { Pagination } from "@/components/ui/pagination";
import { TooltipText } from "@/components/ui/tooltip-text";
import { TooltipProvider } from "@/components/ui/tooltip";
import {
  Dialog,
  DialogContent,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { VisuallyHidden } from "@radix-ui/react-visually-hidden";
import {
  FacilityConfirmFilter,
  type FilterValues,
} from "@/app/facility-confirm/_components/facility-confirm-filter";
import type { Facility } from "@/lib/types";
import { facilityService } from "@/services/facilityService";
import { FacilityDetails } from "./facility-detail";

// Star Rating Component
const StarRating = ({
  rating,
  totalRatings,
}: {
  rating: number;
  totalRatings: number;
}) => {
  const stars = [];
  const fullStars = Math.floor(rating);
  const hasHalfStar = rating % 1 !== 0;

  // Add full stars
  for (let i = 0; i < fullStars; i++) {
    stars.push(
      <Star key={i} className="h-4 w-4 fill-yellow-400 text-yellow-400" />
    );
  }

  // Add half star if needed
  if (hasHalfStar) {
    stars.push(
      <div key="half" className="relative">
        <Star className="h-4 w-4 text-gray-300" />
        <div
          className="absolute inset-0 overflow-hidden"
          style={{ width: `${(rating % 1) * 100}%` }}
        >
          <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
        </div>
      </div>
    );
  }

  // Add empty stars
  const remainingStars = 5 - Math.ceil(rating);
  for (let i = 0; i < remainingStars; i++) {
    stars.push(<Star key={`empty-${i}`} className="h-4 w-4 text-gray-300" />);
  }

  return (
    <div className="flex items-center gap-1">
      <div className="flex items-center">{stars}</div>
      <span className="text-sm text-gray-600 ml-1">
        {rating.toFixed(1)} ({totalRatings})
      </span>
    </div>
  );
};

// Price Range Component
const PriceRange = ({
  minPrice,
  maxPrice,
}: {
  minPrice: number;
  maxPrice: number;
}) => {
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(amount);
  };

  if (minPrice === maxPrice) {
    return <span className="font-medium">{formatCurrency(minPrice)}</span>;
  }

  return (
    <div className="flex flex-col">
      <span className="font-medium">{formatCurrency(minPrice)}</span>
      <span className="text-xs text-muted-foreground">
        to {formatCurrency(maxPrice)}
      </span>
    </div>
  );
};

export function FacilityConfirmTable() {
  const searchParams = useSearchParams();
  const [sortColumn, setSortColumn] = useState("");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc");
  const [selectedRows, setSelectedRows] = useState<Record<string, boolean>>({});
  const [selectAll, setSelectAll] = useState(false);
  const [filterOpen, setFilterOpen] = useState(false);
  const [activeFilters, setActiveFilters] = useState<FilterValues>({
    province: "all",
    status: "all",
    searchTerm: "",
  });
  const [selectedFacility, setSelectedFacility] = useState<string | null>(null);

  // API state
  const [facilities, setFacilities] = useState<Facility[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalItems, setTotalItems] = useState(0);

  // Get search term from URL parameters
  const headerSearchTerm = searchParams.get("q") || "";

  // Wrap fetchFacilities in useCallback to fix dependency warning
  const fetchFacilities = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // Combine header search with filter search term
      const combinedSearchTerm = headerSearchTerm || activeFilters.searchTerm;

      const params = {
        pageNumber: currentPage,
        pageSize: itemsPerPage,
        state:
          activeFilters.status === "all"
            ? undefined
            : (activeFilters.status as "pending" | "approved" | "rejected"),
        province:
          activeFilters.province === "all" ? undefined : activeFilters.province,
        search: combinedSearchTerm || undefined,
        orderBy: sortColumn as "price" | "registeredAt" | undefined,
        sortBy: sortDirection,
      };

      console.log("Fetching with params:", params);
      const response = await facilityService.getFacilities(params);
      console.log("API Response:", response);

      // Handle the paginated response from headers
      if (response && typeof response === "object") {
        setFacilities(response.items || []);
        setTotalPages(response.totalPages || 0);
        setTotalItems(response.totalCount || 0);

        console.log("Pagination info:", {
          currentPage: response.currentPage,
          totalPages: response.totalPages,
          totalItems: response.totalCount,
          pageSize: response.pageSize,
        });
      } else {
        console.warn("Invalid response:", response);
        setFacilities([]);
        setTotalPages(0);
        setTotalItems(0);
      }
    } catch (err) {
      console.error("Failed to fetch facilities:", err);
      setError(
        `Failed to load facilities: ${
          err instanceof Error ? err.message : "Unknown error"
        }`
      );
      setFacilities([]);
      setTotalPages(0);
      setTotalItems(0);
    } finally {
      setLoading(false);
    }
  }, [
    currentPage,
    itemsPerPage,
    activeFilters,
    sortColumn,
    sortDirection,
    headerSearchTerm,
  ]);

  // Callback to handle facility state updates from detail modal
  const handleFacilityUpdate = useCallback(
    (facilityId: string, newState: "Pending" | "Approved" | "Rejected") => {
      console.log("Updating facility state:", facilityId, newState);

      setFacilities((prevFacilities) =>
        prevFacilities.map((facility) =>
          facility.id === facilityId
            ? { ...facility, state: newState }
            : facility
        )
      );
    },
    []
  );

  // Fetch data when filters, pagination, sorting, or header search changes
  useEffect(() => {
    // Reset to first page when search term changes
    if (headerSearchTerm !== (activeFilters.searchTerm || "")) {
      setCurrentPage(1);
    }
    fetchFacilities();
  }, [fetchFacilities, headerSearchTerm, activeFilters.searchTerm]);

  // Update active filters when header search changes
  useEffect(() => {
    if (headerSearchTerm !== activeFilters.searchTerm) {
      setActiveFilters((prev) => ({
        ...prev,
        searchTerm: headerSearchTerm,
      }));
    }
  }, [headerSearchTerm, activeFilters.searchTerm]);

  const handleSort = (column: string) => {
    // Only allow sorting for price and registeredAt
    if (column !== "price" && column !== "registeredAt") {
      return;
    }

    if (sortColumn === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortColumn(column);
      setSortDirection("asc");
    }
  };

  const handleSelectAll = () => {
    const newSelectAll = !selectAll;
    setSelectAll(newSelectAll);

    const newSelectedRows: Record<string, boolean> = {};
    if (newSelectAll) {
      facilities.forEach((facility) => {
        newSelectedRows[facility.id] = true;
      });
    }
    setSelectedRows(newSelectedRows);
  };

  const handleSelectRow = (
    facilityId: string,
    checked: boolean,
    event: React.MouseEvent
  ) => {
    event.stopPropagation();

    setSelectedRows((prev) => ({
      ...prev,
      [facilityId]: checked,
    }));

    const allSelected =
      Object.keys(selectedRows).length === facilities.length - 1 && checked;
    setSelectAll(allSelected);
  };

  const handleRowClick = (facilityId: string) => {
    setSelectedFacility(facilityId);
  };

  const handleApplyFilter = (filters: FilterValues) => {
    setActiveFilters(filters);
    setCurrentPage(1);
  };

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  const handleItemsPerPageChange = (value: string) => {
    const newItemsPerPage = Number(value);
    setItemsPerPage(newItemsPerPage);
    setCurrentPage(1);
  };

  const getSortIcon = (column: string) => {
    // Only show sort icons for sortable columns
    if (column !== "price" && column !== "registeredAt") {
      return null;
    }

    if (sortColumn !== column) return <ArrowUpDown className="ml-2 h-4 w-4" />;
    return sortDirection === "asc" ? (
      <ArrowUp className="ml-2 h-4 w-4" />
    ) : (
      <ArrowDown className="ml-2 h-4 w-4" />
    );
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  };

  const selectedCount = Object.values(selectedRows).filter(Boolean).length;

  const hasActiveFilters =
    (activeFilters.province !== "" && activeFilters.province !== "all") ||
    activeFilters.status !== "all" ||
    activeFilters.searchTerm !== "" ||
    headerSearchTerm !== "";

  const getMainPhotoUrl = (photos: Facility["photos"]) => {
    if (!photos || !Array.isArray(photos) || photos.length === 0) {
      return "/placeholder.svg?height=40&width=40";
    }
    const mainPhoto = photos.find((photo) => photo.isMain);
    return (
      mainPhoto?.url || photos[0]?.url || "/placeholder.svg?height=40&width=40"
    );
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64 bg-white">
        <div className="text-center bg-white p-8 rounded-lg">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Loading facilities...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64 bg-white">
        <div className="text-center bg-white p-8 rounded-lg">
          <p className="text-red-600 mb-4">{error}</p>
          <Button
            onClick={fetchFacilities}
            variant="outline"
            className="bg-white border border-gray-300"
          >
            Try Again
          </Button>
        </div>
      </div>
    );
  }

  return (
    <TooltipProvider>
      <div className="space-y-4 bg-white p-4">
        <div className="flex items-center justify-between bg-white">
          <div className="flex items-center space-x-4 bg-white">
            <h2 className="text-xl font-semibold text-gray-800">
              Facility Management
            </h2>
            <Dialog open={filterOpen} onOpenChange={setFilterOpen}>
              <DialogTrigger asChild>
                <Button
                  variant={hasActiveFilters ? "default" : "outline"}
                  size="sm"
                  className={
                    hasActiveFilters
                      ? "bg-green-600 hover:bg-green-700 text-white"
                      : "bg-white border border-gray-300 text-gray-700 hover:bg-gray-50"
                  }
                >
                  <Filter className="mr-2 h-4 w-4" />
                  {hasActiveFilters ? "Filters Applied" : "Filter"}
                </Button>
              </DialogTrigger>
              <DialogContent className="sm:max-w-[425px] bg-white border border-gray-200 shadow-xl rounded-lg">
                <VisuallyHidden>
                  <DialogTitle>Filter Facilities</DialogTitle>
                </VisuallyHidden>
                <div className="p-4">
                  <h2 className="text-lg font-semibold text-gray-900 mb-4">
                    Filter Facilities
                  </h2>
                  <FacilityConfirmFilter
                    onClose={() => setFilterOpen(false)}
                    onApplyFilter={handleApplyFilter}
                  />
                </div>
              </DialogContent>
            </Dialog>
          </div>

          {selectedCount > 0 && (
            <div className="bg-green-600 text-white px-4 py-2 rounded-full text-sm font-medium">
              {selectedCount} {selectedCount === 1 ? "facility" : "facilities"}{" "}
              selected
            </div>
          )}
        </div>

        <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="bg-gray-50 hover:bg-gray-100">
                  <TableHead className="w-[60px] rounded-tl-xl bg-gray-50">
                    No
                  </TableHead>
                  <TableHead className="w-[300px] bg-gray-50">
                    <div className="flex items-center">Facility Name</div>
                  </TableHead>
                  <TableHead className="w-[200px] bg-gray-50">
                    <div className="flex items-center">Manager Name</div>
                  </TableHead>
                  <TableHead
                    className="w-[150px] cursor-pointer bg-gray-50"
                    onClick={() => handleSort("registeredAt")}
                  >
                    <div className="flex items-center">
                      Register Date
                      {getSortIcon("registeredAt")}
                    </div>
                  </TableHead>
                  <TableHead
                    className="w-[150px] cursor-pointer bg-gray-50"
                    onClick={() => handleSort("price")}
                  >
                    <div className="flex items-center">
                      Price
                      {getSortIcon("price")}
                    </div>
                  </TableHead>
                  <TableHead className="w-[150px] bg-gray-50">
                    <div className="flex items-center">Rating</div>
                  </TableHead>
                  <TableHead className="w-[120px] bg-gray-50">
                    <div className="flex items-center">Status</div>
                  </TableHead>
                  <TableHead className="w-[100px] rounded-tr-xl bg-gray-50">
                    <div
                      className="flex items-center cursor-pointer"
                      onClick={handleSelectAll}
                    >
                      {selectAll ? "Unselect All" : "Select All"}
                    </div>
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody className="bg-white">
                {facilities && facilities.length > 0 ? (
                  facilities.map((facility, index) => (
                    <TableRow
                      key={facility.id}
                      className={`${
                        selectedRows[facility.id] ? "bg-green-50" : "bg-white"
                      } hover:bg-gray-50 transition-colors cursor-pointer`}
                      onClick={() => handleRowClick(facility.id)}
                    >
                      <TableCell className="font-medium bg-white">
                        {(currentPage - 1) * itemsPerPage + index + 1}
                      </TableCell>
                      <TableCell className="w-[300px] bg-white">
                        <div className="flex items-center gap-3">
                          <div className="h-12 w-12 rounded-lg overflow-hidden shadow-sm border flex-shrink-0 bg-white">
                            <Image
                              src={
                                getMainPhotoUrl(facility.photos) ||
                                "/placeholder.svg"
                              }
                              alt={facility.facilityName}
                              width={48}
                              height={48}
                              className="object-cover w-full h-full"
                            />
                          </div>
                          <div className="flex-1 min-w-0 bg-white">
                            <div className="font-medium text-gray-900 truncate">
                              <TooltipText
                                text={facility.facilityName}
                                maxLength={30}
                              />
                            </div>
                            <div className="text-xs text-muted-foreground truncate">
                              <TooltipText
                                text={facility.detailAddress}
                                maxLength={40}
                              />
                            </div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell className="w-[200px] bg-white">
                        <div>
                          <div className="font-medium text-gray-900 truncate">
                            <TooltipText
                              text={facility.managerInfo?.fullName || "N/A"}
                              maxLength={20}
                            />
                          </div>
                          <div className="text-xs text-muted-foreground truncate">
                            <TooltipText
                              text={facility.managerInfo?.email || "N/A"}
                              maxLength={25}
                            />
                          </div>
                        </div>
                      </TableCell>
                      <TableCell className="w-[150px] bg-white">
                        {formatDate(facility.registeredAt)}
                      </TableCell>
                      <TableCell className="w-[150px] bg-white">
                        <PriceRange
                          minPrice={facility.minPrice}
                          maxPrice={facility.maxPrice}
                        />
                      </TableCell>
                      <TableCell className="w-[150px] bg-white">
                        <StarRating
                          rating={facility.ratingAvg}
                          totalRatings={facility.totalRatings}
                        />
                      </TableCell>
                      <TableCell className="w-[120px] bg-white">
                        <span
                          className={`px-3 py-1 rounded-full text-xs font-medium ${
                            facility.state === "Approved"
                              ? "bg-green-100 text-green-800"
                              : facility.state === "Pending"
                              ? "bg-yellow-100 text-yellow-800"
                              : "bg-red-100 text-red-800"
                          }`}
                        >
                          {facility.state}
                        </span>
                      </TableCell>
                      <TableCell
                        className="w-[100px] text-center bg-white"
                        onClick={(e) => {
                          e.stopPropagation();
                        }}
                      >
                        <Checkbox
                          checked={selectedRows[facility.id] || false}
                          onCheckedChange={(checked) => {
                            const syntheticEvent = {
                              stopPropagation: () => {},
                            } as React.MouseEvent;
                            handleSelectRow(
                              facility.id,
                              checked as boolean,
                              syntheticEvent
                            );
                          }}
                          aria-label={`Select ${facility.facilityName}`}
                          className="data-[state=checked]:bg-green-600 data-[state=checked]:border-green-600 bg-white border border-gray-300"
                        />
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow className="bg-white">
                    <TableCell
                      colSpan={8}
                      className="text-center py-8 text-gray-500 bg-white"
                    >
                      <div className="flex flex-col items-center gap-2">
                        <p>No facilities found</p>
                        <p className="text-sm text-gray-400">
                          {hasActiveFilters
                            ? "Try adjusting your filters or search term"
                            : "No data available"}
                        </p>
                        {headerSearchTerm && (
                          <p className="text-sm text-gray-400">
                            {'No results for "'}
                            {headerSearchTerm}
                            {'"'}
                          </p>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
              <TableFooter className="bg-white">
                <TableRow className="bg-white">
                  <TableCell colSpan={8} className="rounded-b-xl p-0 bg-white">
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
      {selectedFacility && (
        <FacilityDetails
          facilityId={selectedFacility}
          open={!!selectedFacility}
          onOpenChange={(open) => {
            if (!open) setSelectedFacility(null);
          }}
          onFacilityUpdate={handleFacilityUpdate}
        />
      )}
    </TooltipProvider>
  );
}
