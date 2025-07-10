"use client"

import type { Comment } from "@/lib/types"
import CommentItem from "./comment-item"

interface CommentListProps {
  comments: Comment[]
  postId: string
}

export default function CommentList({ comments, postId }: CommentListProps) {
  // Sort comments by creation date (oldest first)
  const sortedComments = [...comments].sort((a, b) => {
    return new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
  })

  if (sortedComments.length === 0) {
    return (
      <div className="text-center py-8">
        <div className="text-gray-400 mb-2">
          <svg className="h-12 w-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={1.5}
              d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
            />
          </svg>
        </div>
        <p className="text-gray-500 text-sm">No comments yet</p>
        <p className="text-gray-400 text-xs mt-1">Be the first to share your thoughts</p>
      </div>
    )
  }

  return (
    <div className="space-y-1">
      <div className="flex items-center justify-between mb-4">
        <h4 className="text-sm font-semibold text-gray-900">Comments ({sortedComments.length})</h4>
        <div className="text-xs text-gray-500">Sorted by oldest first</div>
      </div>

      <div className="space-y-2">
        {sortedComments.map((comment, index) => (
          <div key={comment.id} className="relative">
            <CommentItem comment={comment} postId={postId} />
            {/* Connector line for threading visual */}
            {index < sortedComments.length - 1 && <div className="absolute left-6 top-16 w-px h-4 bg-gray-200" />}
          </div>
        ))}
      </div>
    </div>
  )
}
