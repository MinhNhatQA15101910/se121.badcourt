import type { Comment } from "@/lib/types"
import CommentItem from "./comment-item"

interface CommentListProps {
  comments: Comment[]
  postId: string
  onLikeComment: (commentId: string) => void
}

export default function CommentList({ comments, postId, onLikeComment }: CommentListProps) {
  return (
    <div className="space-y-4">
      {comments.map((comment) => (
        <CommentItem key={comment.id} comment={comment} postId={postId} onLike={onLikeComment} />
      ))}
    </div>
  )
}
