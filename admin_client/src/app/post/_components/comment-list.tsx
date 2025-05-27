import type { Comment } from "@/lib/types"
import CommentItem from "./comment-item"

interface CommentListProps {
  comments: Comment[]
  postId: string
  onLikeComment: (commentId: string) => void
}

export default function CommentList({ comments, postId, onLikeComment }: CommentListProps) {
  // Sort comments by creation date (oldest first)
  const sortedComments = [...comments].sort((a, b) => {
    return new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
  })

  return (
    <div className="space-y-4">
      {sortedComments.map((comment) => (
        <CommentItem key={comment.id} comment={comment} postId={postId} onLike={onLikeComment} />
      ))}
    </div>
  )
}
