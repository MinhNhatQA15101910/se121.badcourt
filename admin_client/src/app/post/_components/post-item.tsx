"use client"

import { useState, useRef, useEffect } from "react"
import { formatDistanceToNow } from "date-fns"
import { UserAvatar } from "./user-avatar"
import { Button } from "@/components/ui/button"
import type { Post, User } from "@/lib/types"
import CommentList from "./comment-list"
import CommentInput from "./comment-input"
import { Heart, MessageCircle, Share2, Bookmark, MoreHorizontal, Globe, Lock, Users } from "lucide-react"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Badge } from "@/components/ui/badge"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"
import ImageViewer from "./image-viewer2"

interface PostItemProps {
  post: Post
  onLike: (postId: string) => void
  onBookmark: (postId: string) => void
  onShare: (postId: string) => void
  onAddComment: (postId: string, content: string) => void
  onLikeComment: (postId: string, commentId: string) => void
  currentUser: User
}

export default function PostItem({
  post,
  onLike,
  onBookmark,
  onShare,
  onAddComment,
  onLikeComment,
  currentUser,
}: PostItemProps) {
  const [showAllComments, setShowAllComments] = useState(false)
  const [isCommentInputFocused, setIsCommentInputFocused] = useState(false)
  const [currentMediaIndex, setCurrentMediaIndex] = useState(0)
  const [isImageViewerOpen, setIsImageViewerOpen] = useState(false)
  const commentInputRef = useRef<HTMLInputElement>(null)

  const visibleComments = showAllComments ? post.comments : post.comments.slice(Math.max(0, post.comments.length - 3))

  const hiddenCommentsCount = post.comments.length - visibleComments.length

  const handleLike = () => {
    onLike(post.id)
  }

  const handleBookmark = () => {
    onBookmark(post.id)
  }

  const handleShare = () => {
    onShare(post.id)
  }

  const handleAddComment = (content: string) => {
    onAddComment(post.id, content)
  }

  const handleShowComments = () => {
    setShowAllComments(true)
  }

  const handleFocusCommentInput = () => {
    setIsCommentInputFocused(true)
    if (commentInputRef.current) {
      commentInputRef.current.focus()
    }
  }

  const handleNextMedia = () => {
    if (post.mediaUrls && post.mediaUrls.length > 1) {
      setCurrentMediaIndex((currentMediaIndex + 1) % post.mediaUrls.length)
    }
  }

  const handlePrevMedia = () => {
    if (post.mediaUrls && post.mediaUrls.length > 1) {
      setCurrentMediaIndex((currentMediaIndex - 1 + post.mediaUrls.length) % post.mediaUrls.length)
    }
  }

  const handleOpenImageViewer = () => {
    if (post.mediaUrls && post.mediaUrls.length > 0) {
      setIsImageViewerOpen(true)
    }
  }

  const handleCloseImageViewer = () => {
    setIsImageViewerOpen(false)
  }

  const getPrivacyIcon = () => {
    const privacy = post.privacy || "public"
    switch (privacy) {
      case "private":
        return <Lock className="h-3.5 w-3.5 text-[#565973]" />
      case "friends":
        return <Users className="h-3.5 w-3.5 text-[#565973]" />
      default:
        return <Globe className="h-3.5 w-3.5 text-[#565973]" />
    }
  }

  // Handle keyboard navigation for image viewer
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (!isImageViewerOpen) return

      if (e.key === "ArrowRight") {
        handleNextMedia()
      } else if (e.key === "ArrowLeft") {
        handlePrevMedia()
      } else if (e.key === "Escape") {
        handleCloseImageViewer()
      }
    }

    window.addEventListener("keydown", handleKeyDown)
    return () => window.removeEventListener("keydown", handleKeyDown)
  }, [isImageViewerOpen, currentMediaIndex])

  return (
    <div className="bg-white rounded-xl shadow-sm overflow-hidden">
      <div className="p-4">
        <div className="flex items-center gap-3 mb-3">
          <UserAvatar user={post.author} size="md" showStatus={post.author.isOnline} />
          <div>
            <div className="flex items-center gap-1">
              <span className="font-semibold text-[#0b0f19]">{post.author.username}</span>
              {post.author.verified && (
                <TooltipProvider>
                  <Tooltip>
                    <TooltipTrigger asChild>
                      <div className="h-4 w-4 bg-[#23c16b] rounded-full flex items-center justify-center">
                        <svg
                          className="h-2.5 w-2.5 text-white"
                          fill="currentColor"
                          viewBox="0 0 20 20"
                          xmlns="http://www.w3.org/2000/svg"
                        >
                          <path
                            fillRule="evenodd"
                            d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                            clipRule="evenodd"
                          />
                        </svg>
                      </div>
                    </TooltipTrigger>
                    <TooltipContent>
                      <p>Verified Account</p>
                    </TooltipContent>
                  </Tooltip>
                </TooltipProvider>
              )}
            </div>
            <div className="flex items-center text-xs text-[#565973] gap-1">
              <span>{formatDistanceToNow(post.createdAt, { addSuffix: true })}</span>
              <span>•</span>
              <span className="flex items-center gap-0.5">{getPrivacyIcon()}</span>
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
                    d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"
                  />
                </svg>
                Save post
              </DropdownMenuItem>
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
                    d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"
                  />
                </svg>
                Unfollow @{post.author.username.split(" ")[0].toLowerCase()}
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

        {post.category && (
          <div className="mb-3">
            <Badge variant="outline" className="bg-[#f0f2f5] text-[#565973] hover:bg-[#e4e6eb] border-none">
              #{post.category}
            </Badge>
          </div>
        )}

        {post.mediaUrls && post.mediaUrls.length > 0 && (
          <div
            className="relative mb-4 rounded-xl overflow-hidden bg-[#f0f2f5] cursor-pointer"
            onClick={handleOpenImageViewer}
          >
            <img
              src={post.mediaUrls[currentMediaIndex] || "/placeholder.svg"}
              alt="Post media"
              className="w-full object-cover max-h-[500px]"
            />

            {post.mediaUrls.length > 1 && (
              <>
                <Button
                  variant="ghost"
                  size="icon"
                  className="absolute left-2 top-1/2 transform -translate-y-1/2 h-8 w-8 rounded-full bg-black/30 hover:bg-black/50 text-white"
                  onClick={(e) => {
                    e.stopPropagation()
                    handlePrevMedia()
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
                    handleNextMedia()
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
                  {post.mediaUrls.map((_, index) => (
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
            {post.likes > 0 && (
              <>
                <div className="bg-[#23c16b] rounded-full p-1">
                  <Heart className="h-3 w-3 text-white fill-white" />
                </div>
                <span>{post.likes}</span>
              </>
            )}
          </div>

          <div className="flex items-center gap-3">
            {post.comments.length > 0 && <span>{post.comments.length} comments</span>}

            {post.shares > 0 && <span>{post.shares} shares</span>}
          </div>
        </div>
      </div>

      <div className="border-t border-b border-[#e4e6eb] py-1 px-2">
        <div className="flex items-center justify-around">
          <Button
            variant="ghost"
            className={`flex-1 rounded-md gap-2 ${post.isLiked ? "text-[#23c16b]" : "text-[#565973]"}`}
            onClick={handleLike}
          >
            <Heart className={`h-5 w-5 ${post.isLiked ? "fill-[#23c16b] text-[#23c16b]" : ""}`} />
            Like
          </Button>
          <Button variant="ghost" className="flex-1 rounded-md gap-2 text-[#565973]" onClick={handleFocusCommentInput}>
            <MessageCircle className="h-5 w-5" />
            Comment
          </Button>
          <Button variant="ghost" className="flex-1 rounded-md gap-2 text-[#565973]" onClick={handleShare}>
            <Share2 className="h-5 w-5" />
            Share
          </Button>
          <Button
            variant="ghost"
            className={`flex-1 rounded-md gap-2 ${post.bookmarked ? "text-[#23c16b]" : "text-[#565973]"}`}
            onClick={handleBookmark}
          >
            <Bookmark className={`h-5 w-5 ${post.bookmarked ? "fill-[#23c16b] text-[#23c16b]" : ""}`} />
            Save
          </Button>
        </div>
      </div>

      {post.comments.length > 0 && (
        <div className="p-4 space-y-4">
          {hiddenCommentsCount > 0 && (
            <button className="text-[#565973] text-sm font-medium ml-12" onClick={handleShowComments}>
              View {hiddenCommentsCount} more {hiddenCommentsCount === 1 ? "comment" : "comments"}
            </button>
          )}

          <CommentList comments={visibleComments} postId={post.id} onLikeComment={onLikeComment} />
        </div>
      )}

      <div className="border-t border-[#e4e6eb] p-4 flex items-center gap-3">
        <UserAvatar user={currentUser} size="sm" />
        <CommentInput
          onAddComment={handleAddComment}
          isFocused={isCommentInputFocused}
          onFocusChange={setIsCommentInputFocused}
          inputRef={commentInputRef}
        />
      </div>

      {isImageViewerOpen && post.mediaUrls && (
        <ImageViewer
          images={post.mediaUrls}
          currentIndex={currentMediaIndex}
          onClose={handleCloseImageViewer}
          onNext={handleNextMedia}
          onPrevious={handlePrevMedia}
        />
      )}
    </div>
  )
}

