import type { Post, User, Comment } from "@/lib/types"
import PostItem from "./post-item"

interface PostListProps {
  posts: Post[]
  onLikePost: (postId: string) => void
  onAddComment: (postId: string, content: string) => Promise<Comment>
  onLikeComment: (commentId: string) => void
  currentUser: Partial<User>
}

export default function PostList({ posts, onLikePost, onAddComment, onLikeComment, currentUser }: PostListProps) {
  return (
    <div className="space-y-4">
      {posts.length === 0 ? (
        <div className="bg-white rounded-xl p-8 text-center">
          <p className="text-[#565973] mb-2">No posts yet</p>
          <p className="text-sm text-[#9397ad]">Be the first to share something!</p>
        </div>
      ) : (
        posts.map((post) => (
          <PostItem
            key={post.id}
            post={post}
            onLike={onLikePost}
            onAddComment={onAddComment}
            onLikeComment={onLikeComment}
            currentUser={currentUser}
          />
        ))
      )}
    </div>
  )
}
