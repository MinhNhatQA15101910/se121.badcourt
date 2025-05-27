"use client"

import { useState } from "react"
import { formatDistanceToNow } from "date-fns"
import { UserAvatar } from "./user-avatar"
import type { Comment } from "@/lib/types"
import { MoreHorizontal, ThumbsUp, ImageIcon } from "lucide-react"
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
  onLike: (commentId: string) => void
}

export default function CommentItem({ comment, onLike }: CommentItemProps) {
  const [isImageViewerOpen, setIsImageViewerOpen] = useState(false)
  const [currentImageIndex, setCurrentImageIndex] = useState(0)
  const [imageLoadError, setImageLoadError] = useState<Record<string, boolean>>({})

  const handleLike = () => {
    onLike(comment.id)
  }

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
    <div className="flex gap-3">
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
      <div className="flex-1">
        <div className="bg-[#f0f2f5] rounded-lg p-3 relative group">
          <div className="flex justify-between">
            <span className="font-semibold text-[#0b0f19]">{comment.publisherUsername}</span>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-6 w-6 rounded-full absolute right-2 top-2 opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  <MoreHorizontal className="h-4 w-4 text-[#565973]" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem className="cursor-pointer">Copy text</DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem className="cursor-pointer text-red-500">Report</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
          <p className="text-[#0b0f19] whitespace-pre-line">{comment.content}</p>

          {mediaUrls.length > 0 && (
            <div className="mt-2 flex flex-wrap gap-2">
              {mediaUrls.map((url, index) => (
                <div
                  key={index}
                  className="relative w-20 h-20 rounded-lg overflow-hidden cursor-pointer bg-gray-100"
                  onClick={() => openImageViewer(index)}
                >
                  {imageLoadError[url] ? (
                    <div className="w-full h-full flex items-center justify-center bg-gray-200">
                      <ImageIcon className="h-8 w-8 text-gray-400" />
                    </div>
                  ) : (
                    <img
                      src={url || "/placeholder.svg"}
                      alt="Comment attachment"
                      className="w-full h-full object-cover"
                      onError={() => handleImageError(url)}
                    />
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
        <div className="flex items-center gap-4 mt-1 ml-2 text-xs">
          <button
            className={`flex items-center font-medium ${comment.isLiked ? "text-[#23c16b]" : "text-[#565973]"}`}
            onClick={handleLike}
          >
            <ThumbsUp className={`h-3.5 w-3.5 mr-1 ${comment.isLiked ? "fill-[#23c16b]" : ""}`} />
            <span>Like</span>
            {comment.likesCount > 0 && <span className="ml-1">· {comment.likesCount}</span>}
          </button>
          <span className="text-[#565973]">
            {formatDistanceToNow(new Date(comment.createdAt), {
              addSuffix: true,
            })}
          </span>
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
