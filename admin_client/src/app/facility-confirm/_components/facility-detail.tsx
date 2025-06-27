"use client"

import type React from "react"
import { MapPin, Calendar, X, ExternalLink, CheckCircle, XCircle, Clock, Star } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import { VisuallyHidden } from "@radix-ui/react-visually-hidden"
import { Separator } from "@/components/ui/separator"
import { Badge } from "@/components/ui/badge"
import { useState, useEffect } from "react"
import Image from "next/image"
import { CourtCard } from "@/components/court-card"
import { createImageViewerHTML } from "@/components/image-viewer"
import { facilityService } from "@/services/facilityService"
import { courtService } from "@/services/courtService"
import type { Facility, Court } from "@/lib/types"

interface FacilityDetailsProps {
  facilityId: string
  open: boolean
  onOpenChange: (open: boolean) => void
  onFacilityUpdate?: (facilityId: string, newState: "Pending" | "Approved" | "Rejected") => void
}

export function FacilityDetails({ facilityId, open, onOpenChange, onFacilityUpdate }: FacilityDetailsProps) {
  const [facility, setFacility] = useState<Facility | null>(null)
  const [courts, setCourts] = useState<Court[]>([])
  const [loading, setLoading] = useState(true)
  const [courtsLoading, setCourtsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [actionLoading, setActionLoading] = useState(false)

  // Fetch facility details
  useEffect(() => {
    if (!facilityId || !open) return

    const fetchFacilityDetails = async () => {
      try {
        setLoading(true)
        setError(null)
        console.log("Fetching facility details for:", facilityId)

        const facilityData = await facilityService.getFacilityById(facilityId)
        console.log("Facility data received:", facilityData)
        setFacility(facilityData)
      } catch (err) {
        console.error("Failed to fetch facility details:", err)
        setError(`Failed to load facility details: ${err instanceof Error ? err.message : "Unknown error"}`)
      } finally {
        setLoading(false)
      }
    }

    fetchFacilityDetails()
  }, [facilityId, open])

  // Fetch courts data
  useEffect(() => {
    if (!facilityId || !open) return

    const fetchCourts = async () => {
      try {
        setCourtsLoading(true)
        console.log("Fetching courts for facility:", facilityId)

        const courtsData = await courtService.getCourtsByFacilityId(facilityId)
        console.log("Courts data received:", courtsData)
        setCourts(Array.isArray(courtsData) ? courtsData : [])
      } catch (err) {
        console.error("Failed to fetch courts:", err)
        setCourts([])
      } finally {
        setCourtsLoading(false)
      }
    }

    fetchCourts()
  }, [facilityId, open])

  const handleApproveFacility = async () => {
    if (!facility) return

    try {
      setActionLoading(true)
      console.log("Approving facility:", facilityId)

      await facilityService.approveFacility(facilityId)

      // Update local state
      setFacility((prev) => (prev ? { ...prev, state: "Approved" } : null))

      // Notify parent component to update table
      if (onFacilityUpdate) {
        onFacilityUpdate(facilityId, "Approved")
      }

      console.log("Facility approved successfully")
      // Success - no alert needed, just visual feedback
    } catch (err) {
      console.error("Failed to approve facility:", err)
      const errorMessage = err instanceof Error ? err.message : "Unknown error"

      // Only show alert on error
      if (errorMessage.includes("401") || errorMessage.includes("Unauthorized")) {
        alert("Authorization failed. Please check your login status and try again.")
      } else {
        alert(`Failed to approve facility: ${errorMessage}`)
      }
    } finally {
      setActionLoading(false)
    }
  }

  const handleRejectFacility = async () => {
    if (!facility) return

    try {
      setActionLoading(true)
      console.log("Rejecting facility:", facilityId)

      await facilityService.rejectFacility(facilityId)

      // Update local state
      setFacility((prev) => (prev ? { ...prev, state: "Rejected" } : null))

      // Notify parent component to update table
      if (onFacilityUpdate) {
        onFacilityUpdate(facilityId, "Rejected")
      }

      console.log("Facility rejected successfully")
      // Success - no alert needed, just visual feedback
    } catch (err) {
      console.error("Failed to reject facility:", err)
      const errorMessage = err instanceof Error ? err.message : "Unknown error"

      // Only show alert on error
      if (errorMessage.includes("401") || errorMessage.includes("Unauthorized")) {
        alert("Authorization failed. Please check your login status and try again.")
      } else {
        alert(`Failed to reject facility: ${errorMessage}`)
      }
    } finally {
      setActionLoading(false)
    }
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString("en-US", {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    })
  }

  const getMainPhotoUrl = (photos: Facility["photos"]) => {
    if (!photos || !Array.isArray(photos) || photos.length === 0) {
      return "/placeholder.svg?height=300&width=400"
    }
    const mainPhoto = photos.find((photo) => photo.isMain)
    return mainPhoto?.url || photos[0]?.url || "/placeholder.svg?height=300&width=400"
  }

  if (loading) {
    return (
      <Dialog open={open} onOpenChange={onOpenChange}>
        <DialogContent className="max-w-md sm:max-w-xl md:max-w-2xl p-0 rounded-lg border shadow-lg max-h-[90vh] flex flex-col bg-white">
          <VisuallyHidden>
            <DialogTitle>Loading Facility Details</DialogTitle>
          </VisuallyHidden>
          <div className="flex items-center justify-center h-64 bg-white">
            <div className="text-center bg-white p-8 rounded-lg">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
              <p className="mt-2 text-gray-600">Loading facility details...</p>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    )
  }

  if (error || !facility) {
    return (
      <Dialog open={open} onOpenChange={onOpenChange}>
        <DialogContent className="max-w-md sm:max-w-xl md:max-w-2xl p-0 rounded-lg border shadow-lg max-h-[90vh] flex flex-col bg-white">
          <VisuallyHidden>
            <DialogTitle>Error Loading Facility</DialogTitle>
          </VisuallyHidden>
          <div className="flex items-center justify-center h-64 bg-white">
            <div className="text-center bg-white p-8 rounded-lg">
              <p className="text-red-600 mb-4">{error || "Facility not found"}</p>
              <Button onClick={() => onOpenChange(false)} variant="outline" className="bg-white border border-gray-300">
                Close
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    )
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md sm:max-w-xl md:max-w-2xl p-0 rounded-lg border shadow-lg max-h-[90vh] flex flex-col bg-white overflow-hidden">
        <VisuallyHidden>
          <DialogTitle>Facility Details - {facility.facilityName}</DialogTitle>
        </VisuallyHidden>

        {/* Header with title and close button - fixed */}
        <div className="flex items-center justify-between p-4 border-b bg-white z-10 rounded-t-lg">
          <div className="flex items-center gap-2">
            <h1 className="text-lg font-semibold text-[#27272a]">{facility.facilityName}</h1>
            <StatusBadge status={facility.state} />
          </div>
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8 rounded-full bg-white"
            onClick={() => onOpenChange(false)}
          >
            <X className="w-4 h-4" />
          </Button>
        </div>

        {/* Scrollable content area using native scrolling */}
        <div className="flex-1 overflow-y-auto bg-white">
          {/* Facility image */}
          <div className="relative w-full h-64 bg-[#f2f2f2] flex items-center justify-center">
            <Image
              src={getMainPhotoUrl(facility.photos) || "/placeholder.svg"}
              alt={facility.facilityName}
              width={400}
              height={300}
              className="w-full h-full object-cover"
            />
            <div className="absolute bottom-0 left-0 right-0 bg-[#4b4b4b] text-white p-3 text-sm">
              ID: {facility.id}
            </div>
          </div>

          {/* Location and date info */}
          <div className="p-4 space-y-3 bg-white">
            <div className="flex items-start gap-2">
              <MapPin className="w-5 h-5 shrink-0 text-[#198155] mt-0.5" />
              <span className="text-[#4b4b4b]">
                {facility.detailAddress}, {facility.province}
              </span>
            </div>
            <div className="flex items-center gap-2">
              <Calendar className="w-5 h-5 shrink-0 text-[#198155]" />
              <span className="text-[#4b4b4b]">Registered: {formatDate(facility.registeredAt)}</span>
            </div>
            <div className="flex items-center gap-2">
              <Star className="w-5 h-5 shrink-0 text-yellow-400" />
              <span className="text-[#4b4b4b]">
                Rating: {facility.ratingAvg.toFixed(1)} ({facility.totalRatings} reviews)
              </span>
            </div>
          </div>

          <Separator />

          {/* Facility Information */}
          <div className="p-4 bg-white">
            <h3 className="font-medium text-base mb-3">Facility Information</h3>
            <div className="space-y-3 text-sm">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-[#808089]">Courts Amount</p>
                  <p className="font-medium">{facility.courtsAmount}</p>
                </div>
                <div>
                  <p className="text-[#808089]">Price Range</p>
                  <p className="font-medium">
                    {new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(facility.minPrice)} -{" "}
                    {new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(facility.maxPrice)}
                  </p>
                </div>
              </div>
              <div>
                <p className="text-[#808089]">Description</p>
                <p className="font-medium">{facility.description}</p>
              </div>
              {facility.facebookUrl && (
                <div>
                  <p className="text-[#808089]">Facebook</p>
                  <div className="font-medium text-blue-600 break-all">
                    <a
                      href={facility.facebookUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="hover:underline block"
                      style={{ wordBreak: "break-all", overflowWrap: "break-word" }}
                    >
                      {facility.facebookUrl}
                    </a>
                  </div>
                </div>
              )}
              <div>
                <p className="text-[#808089]">Policy</p>
                <p className="font-medium">{facility.policy}</p>
              </div>
            </div>
          </div>

          <Separator />

          {/* User profile section */}
          <div className="p-4 bg-white">
            <div className="flex items-center gap-4 mb-4">
              <div className="w-16 h-16 rounded-full bg-[#f0f0f0] flex items-center justify-center overflow-hidden">
                {facility.userImageUrl ? (
                  <Image
                    src={facility.userImageUrl || "/placeholder.svg"}
                    alt={facility.managerInfo.fullName}
                    width={64}
                    height={64}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M20 21V19C20 17.9391 19.5786 16.9217 18.8284 16.1716C18.0783 15.4214 17.0609 15 16 15H8C6.93913 15 5.92172 15.4214 5.17157 16.1716C4.42143 16.9217 4 17.9391 4 19V21M16 7C16 9.20914 14.2091 11 12 11C9.79086 11 8 9.20914 8 7C8 4.79086 9.79086 3 12 3C14.2091 3 16 4.79086 16 7Z"
                      stroke="#9CA3AF"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                )}
              </div>
              <div>
                <h2 className="font-medium text-base">{facility.managerInfo.fullName}</h2>
                <p className="text-[#808089] text-sm">Manager ID: {facility.userId}</p>
              </div>
            </div>

            {/* Manager's additional information */}
            <div className="space-y-3 text-sm">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-[#808089]">Email</p>
                  <p className="font-medium">{facility.managerInfo.email}</p>
                </div>
                <div>
                  <p className="text-[#808089]">Phone Number</p>
                  <p className="font-medium">{facility.managerInfo.phoneNumber}</p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-[#808089]">Citizen ID</p>
                  <p className="font-medium">{facility.managerInfo.citizenId}</p>
                </div>
              </div>
            </div>
          </div>

          <Separator />

          {/* Document sections */}
          <div className="p-4 space-y-6 bg-white">
            <DocumentSection
              title="Photos of citizen identification card"
              images={[facility.managerInfo.citizenImageFront.url, facility.managerInfo.citizenImageBack.url].filter(
                Boolean,
              )}
              sectionId="id-card"
            />

            <DocumentSection
              title="Photos of bank card"
              images={[facility.managerInfo.bankCardFront.url, facility.managerInfo.bankCardBack.url].filter(Boolean)}
              sectionId="bank-card"
            />

            <DocumentSection
              title="Photos of business license"
              images={facility.managerInfo.businessLicenseImages.map((img) => img.url).filter(Boolean)}
              sectionId="business-license"
            />

            <DocumentSection
              title="Facility Photos"
              images={facility.photos.map((photo) => photo.url).filter(Boolean)}
              sectionId="facility-photos"
            />
          </div>

          {/* Courts Information */}
          <Separator className="my-2" />

          <div className="p-4 space-y-6 bg-white">
            <h3 className="font-medium text-base">Courts Information</h3>

            {courtsLoading ? (
              <div className="flex items-center justify-center py-8">
                <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-green-600"></div>
                <span className="ml-2 text-gray-600">Loading courts...</span>
              </div>
            ) : courts.length > 0 ? (
              <div className="space-y-4">
                <div className="text-sm text-gray-600">
                  Found {courts.length} court{courts.length !== 1 ? "s" : ""}
                </div>
                <div className="grid gap-3 sm:grid-cols-1 lg:grid-cols-2">
                  {courts.map((court) => (
                    <CourtCard key={court.id} court={court} />
                  ))}
                </div>
              </div>
            ) : (
              <div className="text-center py-8 text-gray-500">
                <p>No courts found for this facility</p>
              </div>
            )}
          </div>
        </div>

        {/* Footer buttons - fixed */}
        <div className="flex gap-3 p-4 border-t bg-white z-10 rounded-b-lg">
          {facility.state !== "Rejected" && (
            <Button
              variant="outline"
              className="flex-1 border-red-500 text-red-600 hover:bg-red-50 hover:text-red-700"
              onClick={handleRejectFacility}
              disabled={actionLoading}
            >
              {actionLoading ? "Processing..." : "Reject"}
            </Button>
          )}
          {facility.state !== "Approved" && (
            <Button
              className="flex-1 bg-[#23c16b] hover:bg-[#23c16b]/90 text-white"
              onClick={handleApproveFacility}
              disabled={actionLoading}
            >
              {actionLoading ? "Processing..." : "Approve"}
            </Button>
          )}
          {(facility.state === "Approved" || facility.state === "Rejected") && (
            <Button
              variant="outline"
              className="flex-1 border-[#23c16b] text-[#23c16b] hover:bg-[#23c16b]/10 hover:text-[#23c16b]"
              onClick={() => onOpenChange(false)}
            >
              Close
            </Button>
          )}
        </div>
      </DialogContent>
    </Dialog>
  )
}

function StatusBadge({ status }: { status: "Pending" | "Approved" | "Rejected" }) {
  switch (status) {
    case "Approved":
      return (
        <Badge className="bg-green-100 text-green-800 hover:bg-green-100 flex items-center gap-1">
          <CheckCircle className="w-3 h-3" /> Approved
        </Badge>
      )
    case "Rejected":
      return (
        <Badge className="bg-red-100 text-red-800 hover:bg-red-100 flex items-center gap-1">
          <XCircle className="w-3 h-3" /> Rejected
        </Badge>
      )
    default:
      return (
        <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-100 flex items-center gap-1">
          <Clock className="w-3 h-3" /> Pending
        </Badge>
      )
  }
}

function DocumentSection({
  title,
  images,
}: {
  title: string
  images: string[]
  sectionId: string
}) {
  const handleImageClick = (imageUrl: string, index: number, e: React.MouseEvent) => {
    e.preventDefault()

    // Open a new window with the image
    const newWindow = window.open("", "_blank")
    if (!newWindow) return

    // Create HTML content for the new window with image viewer functionality
    const html = createImageViewerHTML(title, imageUrl, index, images)

    // Write the HTML content to the new window
    newWindow.document.write(html)
    newWindow.document.close()
  }

  if (!images || images.length === 0) {
    return (
      <div>
        <h3 className="font-medium text-sm mb-3">{title}</h3>
        <div className="text-sm text-gray-500 italic">No images available</div>
      </div>
    )
  }

  return (
    <div>
      <h3 className="font-medium text-sm mb-3">{title}</h3>
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
        {images.map((image, index) => (
          <div
            key={index}
            className="relative group aspect-square bg-[#f2f4f5] rounded-md overflow-hidden border flex items-center justify-center cursor-pointer"
            onClick={(e) => handleImageClick(image, index, e)}
          >
            <Image
              src={image || "/placeholder.svg"}
              alt={`${title} - Image ${index + 1}`}
              width={500}
              height={500}
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100">
              <ExternalLink className="w-4 h-4 text-white" />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
