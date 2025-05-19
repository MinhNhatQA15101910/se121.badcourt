"use client"

import { useState } from "react"
import { formatDistanceToNow } from "date-fns"
import { UserAvatar } from "./user-avatar"
import type { Comment } from "@/lib/types"
import { MoreHorizontal } from "lucide-react"
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
  onLike: (postId: string, commentId: string) => void
}

export default function CommentItem({ comment, postId, onLike }: CommentItemProps) {
  const [showReplies, setShowReplies] = useState(false)

  const handleLike = () => {
    onLike(postId, comment.id)
  }

  return (
    <div className="flex gap-3">
      <UserAvatar user={comment.author} size="sm" />
      <div className="flex-1">
        <div className="bg-[#f0f2f5] rounded-lg p-3 relative group">
          <div className="flex justify-between">
            <span className="font-semibold text-[#0b0f19]">{comment.author.username}</span>
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
                <DropdownMenuItem className="cursor-pointer">Edit</DropdownMenuItem>
                <DropdownMenuItem className="cursor-pointer">Copy text</DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem className="cursor-pointer text-red-500">Delete</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
          <p className="text-[#0b0f19] whitespace-pre-line">{comment.content}</p>
        </div>
        <div className="flex items-center gap-4 mt-1 ml-2 text-xs">
          <button
            className={`font-medium ${comment.isLiked ? "text-[#23c16b]" : "text-[#565973]"}`}
            onClick={handleLike}
          >
            Like
            {comment.likes > 0 && <span className="ml-1">· {comment.likes}</span>}
          </button>
          <button className="font-medium text-[#565973]">Reply</button>
          <span className="text-[#565973]">{formatDistanceToNow(comment.createdAt, { addSuffix: true })}</span>
        </div>

        {comment.replies && comment.replies.length > 0 && (
          <div className="mt-2 ml-2">
            {!showReplies ? (
              <button
                className="text-[#565973] text-xs font-medium flex items-center gap-1"
                onClick={() => setShowReplies(true)}
              >
                <svg
                  className="h-4 w-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
                {comment.replies.length} {comment.replies.length === 1 ? "reply" : "replies"}
              </button>
            ) : (
              <div className="space-y-3 mt-3">
                {comment.replies.map((reply) => (
                  <div key={reply.id} className="flex gap-2">
                    <UserAvatar user={reply.author} size="xs" />
                    <div className="flex-1">
                      <div className="bg-[#f0f2f5] rounded-lg p-2">
                        <div className="font-semibold text-[#0b0f19] text-sm">{reply.author.username}</div>
                        <p className="text-[#0b0f19] text-sm">{reply.content}</p>
                      </div>
                      <div className="flex items-center gap-3 mt-1 text-xs">
                        <button className="font-medium text-[#565973]">Like</button>
                        <button className="font-medium text-[#565973]">Reply</button>
                        <span className="text-[#565973]">
                          {formatDistanceToNow(reply.createdAt, { addSuffix: true })}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
                <button
                  className="text-[#565973] text-xs font-medium flex items-center gap-1"
                  onClick={() => setShowReplies(false)}
                >
                  <svg
                    className="h-4 w-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 15l7-7 7 7" />
                  </svg>
                  Hide replies
                </button>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

