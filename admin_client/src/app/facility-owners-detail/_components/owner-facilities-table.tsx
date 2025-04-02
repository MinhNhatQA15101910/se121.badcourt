"use client";

import { useState, useEffect } from "react";
import { ArrowUpDown, ArrowUp, ArrowDown } from "lucide-react";
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
import { Pagination } from "@/components/ui/pagination";
import { TooltipText } from "@/components/ui/tooltip-text";
import { TooltipProvider } from "@/components/ui/tooltip";
import { getFacilitiesByOwnerId, formatDate, formatCurrency } from "@/lib/data";
import type { Facility } from "@/lib/types";
import { FacilityDetails } from "@/components/facility-detail";

interface OwnerFacilitiesTableProps {
  ownerId: string;
}

export function OwnerFacilitiesTable({ ownerId }: OwnerFacilitiesTableProps) {
  const [facilities, setFacilities] = useState<Facility[]>([]);
  const [sortColumn, setSortColumn] = useState("");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc");
  const [selectedFacility, setSelectedFacility] = useState<string | null>(null);

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(5);

  useEffect(() => {
    // Fetch facilities for this owner
    const ownerFacilities = getFacilitiesByOwnerId(ownerId);
    setFacilities(ownerFacilities);
  }, [ownerId]);

  const handleRowClick = (facilityId: string) => {
    setSelectedFacility(facilityId)
  }

  const handleSort = (column: string) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortColumn(column);
      setSortDirection("asc");
    }
  };

  const sortedFacilities = [...facilities].sort((a, b) => {
    if (sortColumn === "") return 0;

    const aValue = a[sortColumn as keyof Facility];
    const bValue = b[sortColumn as keyof Facility];

    if (sortColumn === "registerDate") {
      // Sort dates
      const aDate = new Date(aValue.toString());
      const bDate = new Date(bValue.toString());
      return sortDirection === "asc"
        ? aDate.getTime() - bDate.getTime()
        : bDate.getTime() - aDate.getTime();
    }

    if (typeof aValue === "number" && typeof bValue === "number") {
      return sortDirection === "asc" ? aValue - bValue : bValue - aValue;
    }

    // Sort strings
    if (aValue < bValue) return sortDirection === "asc" ? -1 : 1;
    if (aValue > bValue) return sortDirection === "asc" ? 1 : -1;
    return 0;
  });

  // Calculate pagination
  const totalPages = Math.ceil(sortedFacilities.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedFacilities = sortedFacilities.slice(
    startIndex,
    startIndex + itemsPerPage
  );

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  const handleItemsPerPageChange = (value: string) => {
    setItemsPerPage(Number(value));
    setCurrentPage(1); // Reset to first page when changing items per page
  };

  const getSortIcon = (column: string) => {
    if (sortColumn !== column) return <ArrowUpDown className="ml-2 h-4 w-4" />;
    return sortDirection === "asc" ? (
      <ArrowUp className="ml-2 h-4 w-4" />
    ) : (
      <ArrowDown className="ml-2 h-4 w-4" />
    );
  };

  if (facilities.length === 0) {
    return (
      <div className="p-8 text-center">
        <p className="text-gray-500">No facilities found for this owner.</p>
      </div>
    );
  }

  return (
    <TooltipProvider>
      <div className="overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow className="bg-muted/30 hover:bg-muted/40">
              <TableHead className="w-[60px]">No</TableHead>
              <TableHead
                className="cursor-pointer"
                onClick={() => handleSort("facilityName")}
              >
                <div className="flex items-center">
                  Facility Name
                  {getSortIcon("facilityName")}
                </div>
              </TableHead>
              <TableHead
                className="cursor-pointer"
                onClick={() => handleSort("facilityId")}
              >
                <div className="flex items-center">
                  Facility ID
                  {getSortIcon("facilityId")}
                </div>
              </TableHead>
              <TableHead
                className="cursor-pointer"
                onClick={() => handleSort("registerDate")}
              >
                <div className="flex items-center">
                  Register Date
                  {getSortIcon("registerDate")}
                </div>
              </TableHead>
              <TableHead
                className="cursor-pointer"
                onClick={() => handleSort("revenue")}
              >
                <div className="flex items-center">
                  Revenue
                  {getSortIcon("revenue")}
                </div>
              </TableHead>
              <TableHead
                className="cursor-pointer"
                onClick={() => handleSort("status")}
              >
                <div className="flex items-center">
                  Status
                  {getSortIcon("status")}
                </div>
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {paginatedFacilities.map((facility, index) => (
              <TableRow
                key={facility.facilityId}
                className="hover:bg-muted/20 transition-colors cursor-pointer"
                onClick={() => handleRowClick(facility.facilityId)}
              >
                <TableCell className="font-medium">
                  {startIndex + index + 1}
                </TableCell>
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
                        <TooltipText
                          text={facility.facilityName}
                          maxLength={25}
                        />
                      </div>
                      <div className="text-xs text-muted-foreground max-w-[200px]">
                        <TooltipText
                          text={facility.facilityAddress}
                          maxLength={30}
                        />
                      </div>
                    </div>
                  </div>
                </TableCell>
                <TableCell className="font-mono text-sm">
                  {facility.facilityId}
                </TableCell>
                <TableCell>{formatDate(facility.registerDate)}</TableCell>
                <TableCell className="font-medium text-left">
                  {formatCurrency(facility.revenue)}
                </TableCell>
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
              </TableRow>
            ))}
          </TableBody>
          <TableFooter>
            <TableRow>
              <TableCell colSpan={6} className="p-0">
                <Pagination
                  currentPage={currentPage}
                  totalPages={totalPages}
                  totalItems={facilities.length}
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
      {selectedFacility && (
        <FacilityDetails
          facilityId={selectedFacility}
          open={!!selectedFacility}
          onOpenChange={(open) => {
            if (!open) setSelectedFacility(null);
          }}
        />
      )}
    </TooltipProvider>
  );
}
