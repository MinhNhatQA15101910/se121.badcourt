import type { Post as PostType, User } from "@/lib/types"
import PostItem from "./post-item"

interface PostListProps {
  posts: PostType[]
  onLikePost: (postId: string) => void
  onBookmarkPost: (postId: string) => void
  onSharePost: (postId: string) => void
  onAddComment: (postId: string, content: string) => void
  onLikeComment: (postId: string, commentId: string) => void
  currentUser: User
}

export default function PostList({
  posts,
  onLikePost,
  onBookmarkPost,
  onSharePost,
  onAddComment,
  onLikeComment,
  currentUser,
}: PostListProps) {
  return (
    <div className="space-y-4">
      {posts.map((post) => (
        <PostItem
          key={post.id}
          post={post}
          onLike={onLikePost}
          onBookmark={onBookmarkPost}
          onShare={onSharePost}
          onAddComment={onAddComment}
          onLikeComment={onLikeComment}
          currentUser={currentUser}
        />
      ))}
    </div>
  )
}

