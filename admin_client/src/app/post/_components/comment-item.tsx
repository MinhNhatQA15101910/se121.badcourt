"use client"

import { useState } from "react"
import { formatDistanceToNow } from "date-fns"
import { UserAvatar } from "./user-avatar"
import type { Comment } from "@/lib/types"
import { MoreHorizontal, ImageIcon, Clock } from "lucide-react"
import ImageViewer from "./image-viewer2"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Button } from "@/components/ui/button"

interface CommentItemProps {
  comment: Comment
  postId: string
}

export default function CommentItem({ comment }: CommentItemProps) {
  const [isImageViewerOpen, setIsImageViewerOpen] = useState(false)
  const [currentImageIndex, setCurrentImageIndex] = useState(0)
  const [imageLoadError, setImageLoadError] = useState<Record<string, boolean>>({})

  // Map resources to mediaUrls for compatibility with the UI
  const mediaUrls = comment.resources
    ? comment.resources.filter((resource) => resource.fileType === "Image").map((resource) => resource.url)
    : []

  const openImageViewer = (index: number) => {
    setCurrentImageIndex(index)
    setIsImageViewerOpen(true)
    console.log("Opening image viewer with URLs:", mediaUrls, "at index:", index)
  }

  const handleNextImage = () => {
    setCurrentImageIndex((prev) => (prev + 1) % mediaUrls.length)
  }

  const handlePreviousImage = () => {
    setCurrentImageIndex((prev) => (prev - 1 + mediaUrls.length) % mediaUrls.length)
  }

  const handleImageError = (url: string) => {
    console.error("Failed to load image:", url)
    setImageLoadError((prev) => ({ ...prev, [url]: true }))
  }

  return (
    <div className="flex gap-3 group hover:bg-gray-50/50 p-3 rounded-lg transition-colors duration-200">
      <div className="flex-shrink-0">
        <UserAvatar
          user={{
            id: comment.publisherId,
            username: comment.publisherUsername,
            email: comment.publisherImageUrl,
            photoUrl: comment.publisherImageUrl,
            token: "",
            roles: [],
            isOnline: false,
            verified: false,
          }}
          size="sm"
        />
      </div>

      <div className="flex-1 min-w-0">
        <div className="bg-white border border-gray-200 rounded-xl p-4 shadow-sm hover:shadow-md transition-shadow duration-200 relative">
          {/* Header */}
          <div className="flex items-start justify-between mb-2">
            <div className="flex items-center gap-2">
              <span className="font-semibold text-gray-900 text-sm">{comment.publisherUsername}</span>
              <div className="flex items-center gap-1 text-xs text-gray-500">
                <Clock className="h-3 w-3" />
                <span>
                  {formatDistanceToNow(new Date(comment.createdAt), {
                    addSuffix: true,
                  })}
                </span>
              </div>
            </div>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-7 w-7 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-200 hover:bg-gray-100"
                >
                  <MoreHorizontal className="h-4 w-4 text-gray-500" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-48">
                <DropdownMenuItem className="cursor-pointer text-sm">
                  <svg className="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
                    />
                  </svg>
                  Copy text
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem className="cursor-pointer text-red-600 text-sm">
                  <svg className="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                    />
                  </svg>
                  Report comment
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>

          {/* Content */}
          <div className="text-gray-800 text-sm leading-relaxed whitespace-pre-line mb-3">{comment.content}</div>

          {/* Images */}
          {mediaUrls.length > 0 && (
            <div className="mt-3">
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
                {mediaUrls.slice(0, 4).map((url, index) => (
                  <div
                    key={index}
                    className="relative aspect-square rounded-lg overflow-hidden cursor-pointer bg-gray-100 hover:opacity-90 transition-opacity duration-200 group/image"
                    onClick={() => openImageViewer(index)}
                  >
                    {imageLoadError[url] ? (
                      <div className="w-full h-full flex items-center justify-center bg-gray-200">
                        <ImageIcon className="h-6 w-6 text-gray-400" />
                      </div>
                    ) : (
                      <>
                        <img
                          src={url || "/placeholder.svg"}
                          alt="Comment attachment"
                          className="w-full h-full object-cover transition-transform duration-200 group-hover/image:scale-105"
                          onError={() => handleImageError(url)}
                        />
                        <div className="absolute inset-0 bg-black/0 group-hover/image:bg-black/10 transition-colors duration-200" />
                      </>
                    )}

                    {/* Show count overlay for last image if there are more than 4 images */}
                    {index === 3 && mediaUrls.length > 4 && (
                      <div className="absolute inset-0 bg-black/60 flex items-center justify-center">
                        <span className="text-white font-semibold text-sm">+{mediaUrls.length - 4}</span>
                      </div>
                    )}
                  </div>
                ))}
              </div>

              {mediaUrls.length > 4 && (
                <button
                  onClick={() => openImageViewer(0)}
                  className="mt-2 text-xs text-blue-600 hover:text-blue-800 font-medium transition-colors duration-200"
                >
                  View all {mediaUrls.length} images
                </button>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Image Viewer Modal */}
      {isImageViewerOpen && mediaUrls.length > 0 && (
        <ImageViewer
          images={mediaUrls}
          currentIndex={currentImageIndex}
          onClose={() => setIsImageViewerOpen(false)}
          onNext={handleNextImage}
          onPrevious={handlePreviousImage}
        />
      )}
    </div>
  )
}
