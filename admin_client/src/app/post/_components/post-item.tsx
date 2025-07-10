"use client"

import { useState, useRef, useEffect } from "react"
import { formatDistanceToNow } from "date-fns"
import { UserAvatar } from "./user-avatar"
import { Button } from "@/components/ui/button"
import type { Post, User, Comment } from "@/lib/types"
import CommentList from "./comment-list"
import Image from "next/image"
import { MoreHorizontal, Globe, ThumbsUp } from "lucide-react"

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { commentService } from "@/services/commentService"
import ImageViewer from "./image-viewer2"

interface PostItemProps {
  post: Post
  currentUser: Partial<User>
}

export default function PostItem({ post }: PostItemProps) {
  const [showAllComments, setShowAllComments] = useState(false)
  const [currentMediaIndex, setCurrentMediaIndex] = useState(0)
  const [isImageViewerOpen, setIsImageViewerOpen] = useState(false)
  const [comments, setComments] = useState<Comment[]>([])
  const [loadingComments, setLoadingComments] = useState(false)
  const hasFetchedRef = useRef(false)

  // Fetch comments when component mounts
  useEffect(() => {
    // Chỉ fetch comments một lần khi component mount
    if (!hasFetchedRef.current) {
      const fetchComments = async () => {
        try {
          setLoadingComments(true)
          const fetchedComments = await commentService.getComments(post.id)
          setComments(fetchedComments)
        } catch (err) {
          console.error("Failed to fetch comments:", err)
        } finally {
          setLoadingComments(false)
        }
      }

      fetchComments()
      hasFetchedRef.current = true
    }
  }, [post.id])

  const visibleComments = showAllComments ? comments : comments.slice(Math.max(0, comments.length - 3))
  const hiddenCommentsCount = comments.length - visibleComments.length

  const handleShowComments = () => {
    setShowAllComments(true)
  }

  // Map resources to mediaUrls for compatibility with the UI
  const mediaUrls = post.resources
    ? post.resources.filter((resource) => resource.fileType === "Image").map((resource) => resource.url)
    : []

  const handleOpenImageViewer = () => {
    if (mediaUrls.length > 0) {
      setIsImageViewerOpen(true)
    }
  }

  const handleCloseImageViewer = () => {
    setIsImageViewerOpen(false)
  }

  const handleNextImage = () => {
    setCurrentMediaIndex((prev) => (prev + 1) % mediaUrls.length)
  }

  const handlePreviousImage = () => {
    setCurrentMediaIndex((prev) => (prev - 1 + mediaUrls.length) % mediaUrls.length)
  }

  return (
    <div className="bg-white rounded-xl shadow-sm overflow-hidden">
      <div className="p-4">
        <div className="flex items-center gap-3 mb-3">
          <UserAvatar
            user={{
              id: post.publisherId,
              username: post.publisherUsername,
              email: post.publisherImageUrl,
              photoUrl: post.publisherImageUrl,
              token: "",
              roles: [],
              isOnline: false,
              verified: false,
            }}
            size="md"
          />
          <div>
            <div className="flex items-center gap-1">
              <span className="font-semibold text-[#0b0f19]">{post.publisherUsername}</span>
            </div>
            <div className="flex items-center text-xs text-[#565973] gap-1">
              <span>{formatDistanceToNow(new Date(post.createdAt), { addSuffix: true })}</span>
              <span>•</span>
              <span className="flex items-center gap-0.5">
                <Globe className="h-3.5 w-3.5 text-[#565973]" />
              </span>
            </div>
          </div>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="h-8 w-8 ml-auto rounded-full hover:bg-[#f0f2f5]">
                <MoreHorizontal className="h-5 w-5 text-[#565973]" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem className="cursor-pointer">
                <svg
                  className="h-4 w-4 mr-2"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                  />
                </svg>
                Hide post
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem className="cursor-pointer text-red-500">
                <svg
                  className="h-4 w-4 mr-2"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                  />
                </svg>
                Report post
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        {post.title && <h3 className="text-xl font-bold text-[#0b0f19] mb-2">{post.title}</h3>}

        <p className="text-[#0b0f19] mb-4 whitespace-pre-line">{post.content}</p>

        {mediaUrls.length > 0 && (
          <div
            className="relative mb-4 rounded-xl overflow-hidden bg-[#f0f2f5] cursor-pointer"
            onClick={handleOpenImageViewer}
          >
            <div className="relative w-full max-h-[500px] h-[500px]">
              <Image
                src={mediaUrls[currentMediaIndex] || "/placeholder.svg"}
                alt="Post media"
                fill
                className="object-cover"
                sizes="100vw"
              />
            </div>

            {mediaUrls.length > 1 && (
              <>
                <Button
                  variant="ghost"
                  size="icon"
                  className="absolute left-2 top-1/2 transform -translate-y-1/2 h-8 w-8 rounded-full bg-black/30 hover:bg-black/50 text-white"
                  onClick={(e) => {
                    e.stopPropagation()
                    setCurrentMediaIndex((currentMediaIndex - 1 + mediaUrls.length) % mediaUrls.length)
                  }}
                >
                  <svg
                    className="h-5 w-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                  </svg>
                </Button>

                <Button
                  variant="ghost"
                  size="icon"
                  className="absolute right-2 top-1/2 transform -translate-y-1/2 h-8 w-8 rounded-full bg-black/30 hover:bg-black/50 text-white"
                  onClick={(e) => {
                    e.stopPropagation()
                    setCurrentMediaIndex((currentMediaIndex + 1) % mediaUrls.length)
                  }}
                >
                  <svg
                    className="h-5 w-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                </Button>

                <div className="absolute bottom-2 left-1/2 transform -translate-x-1/2 flex gap-1">
                  {mediaUrls.map((_, index) => (
                    <div
                      key={index}
                      className={`h-1.5 w-1.5 rounded-full ${index === currentMediaIndex ? "bg-white" : "bg-white/50"}`}
                    />
                  ))}
                </div>
              </>
            )}
          </div>
        )}

        <div className="flex items-center justify-between text-sm text-[#565973] mb-1">
          <div className="flex items-center gap-1">
            {post.likesCount > 0 && (
              <>
                <div className="bg-[#23c16b] rounded-full p-1">
                  <ThumbsUp className="h-3 w-3 text-white fill-white" />
                </div>
                <span>{post.likesCount}</span>
              </>
            )}
          </div>

          <div className="flex items-center gap-3">
            {post.commentsCount > 0 && <span>{post.commentsCount} comments</span>}
          </div>
        </div>
      </div>

      {loadingComments && (
        <div className="p-4">
          <div className="animate-pulse space-y-3">
            <div className="flex gap-3">
              <div className="rounded-full bg-gray-200 h-8 w-8"></div>
              <div className="flex-1">
                <div className="h-20 bg-gray-200 rounded-lg"></div>
              </div>
            </div>
            <div className="flex gap-3">
              <div className="rounded-full bg-gray-200 h-8 w-8"></div>
              <div className="flex-1">
                <div className="h-16 bg-gray-200 rounded-lg"></div>
              </div>
            </div>
          </div>
        </div>
      )}

      {!loadingComments && (
        <div className="p-4 space-y-4">
          {comments.length > 0 ? (
            <>
              {hiddenCommentsCount > 0 && (
                <button className="text-[#565973] text-sm font-medium ml-12" onClick={handleShowComments}>
                  View {hiddenCommentsCount} more {hiddenCommentsCount === 1 ? "comment" : "comments"}
                </button>
              )}

              <CommentList comments={visibleComments} postId={post.id} />
            </>
          ) : null}
        </div>
      )}

      {isImageViewerOpen && mediaUrls.length > 0 && (
        <ImageViewer
          images={mediaUrls}
          currentIndex={currentMediaIndex}
          onClose={handleCloseImageViewer}
          onNext={handleNextImage}
          onPrevious={handlePreviousImage}
        />
      )}
    </div>
  )
}
