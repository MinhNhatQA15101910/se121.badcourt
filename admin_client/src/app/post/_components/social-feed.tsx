"use client";

import { useState, useEffect, useCallback } from "react";
import PostCreator from "./post-creator";
import PostList from "./post-list";
import type { Post, Comment } from "@/lib/types";
import { useAuth } from "@/hooks/use-auth";
import { postService } from "@/services/postService";
import { commentService } from "@/services/commentService";
import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { RefreshCw } from "lucide-react";

export default function SocialFeed() {
  /* --------------------------- State & hooks --------------------------- */
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { user } = useAuth();
  const [isCreatingPost, setIsCreatingPost] = useState(false);

  /* ------------------------- Fetch helpers ---------------------------- */
  const fetchPosts = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const fetchedPosts = await postService.getPosts();
      setPosts(fetchedPosts);
    } catch (err) {
      console.error("Failed to fetch posts:", err);
      if (err instanceof Error) {
        setError(`Failed to load posts: ${err.message}`);
      } else {
        setError("Failed to load posts. Please try again later.");
      }
    } finally {
      setLoading(false);
    }
  }, []);

  /* -------------------------- Life‑cycle ------------------------------ */
  useEffect(() => {
    fetchPosts();
  }, [fetchPosts]);

  /* -------------------------- Actions -------------------------------- */
  const handleRetry = () => {
    fetchPosts();
  };

  const handleCreatePost = async (
    content: string,
    files: File[] = [],
    category?: string,
  ) => {
    try {
      setIsCreatingPost(true);
      console.log("Creating post, isCreatingPost set to true");

      // Fake delay to visualise loading indicator
      await new Promise((resolve) => setTimeout(resolve, 2000));

      const newPostData = {
        title:
          content.split(" ").slice(0, 7).join(" ") +
          (content.split(" ").length > 7 ? "..." : ""),
        content,
        category: category || "Sharing",
        resources: files,
      };

      const newPost = await postService.createPost(newPostData);
      setPosts([newPost, ...posts]);
    } catch (err) {
      console.error("Failed to create post:", err);
    } finally {
      setIsCreatingPost(false);
      console.log("Post creation completed, isCreatingPost set to false");
    }
  };

  const handleLikePost = async (postId: string) => {
    try {
      await postService.toggleLikePost(postId);
      setPosts((prev) =>
        prev.map((post) =>
          post.id === postId
            ? {
                ...post,
                likesCount: post.isLiked
                  ? post.likesCount - 1
                  : post.likesCount + 1,
                isLiked: !post.isLiked,
              }
            : post,
        ),
      );
    } catch (err) {
      console.error("Failed to like post:", err);
    }
  };

  const handleAddComment = async (
    postId: string,
    content: string,
  ): Promise<Comment> => {
    try {
      const newComment = await commentService.createComment({ postId, content });
      setPosts((prev) =>
        prev.map((post) =>
          post.id === postId
            ? { ...post, commentsCount: post.commentsCount + 1 }
            : post,
        ),
      );
      return newComment;
    } catch (err) {
      console.error("Failed to add comment:", err);
      throw err;
    }
  };

  const handleLikeComment = async (commentId: string) => {
    try {
      await commentService.toggleLikeComment(commentId);
      // optional optimistic UI updates for comments
    } catch (err) {
      console.error("Failed to like comment:", err);
    }
  };

  /* ---------------------------- UI ----------------------------------- */
  if (loading) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-8">
        <div className="animate-pulse space-y-4">
          <div className="h-32 bg-gray-200 rounded-xl" />
          <div className="h-64 bg-gray-200 rounded-xl" />
          <div className="h-64 bg-gray-200 rounded-xl" />
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-8">
        <Alert variant="destructive" className="mb-4">
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>{error}</AlertDescription>
        </Alert>
        <Button onClick={handleRetry} className="flex items-center gap-2">
          <RefreshCw className="h-4 w-4" /> Try Again
        </Button>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto px-4 space-y-6">
      {user && (
        <PostCreator
          onCreatePost={handleCreatePost}
          currentUser={user}
          isCreatingPost={isCreatingPost}
        />
      )}

      <div className="flex justify-between items-center">
        <h2 className="text-xl font-bold text-[#0b0f19]">Recent Posts</h2>
        <div className="relative">
          <select
            className="appearance-none bg-white text-[#565973] py-1 px-4 pr-8 rounded-lg border border-[#e4e6eb] focus:outline-none focus:ring-2 focus:ring-[#23c16b]"
            defaultValue="all"
          >
            <option value="all">All Posts</option>
            <option value="Sharing">Sharing</option>
            <option value="Question">Question</option>
            <option value="News">News</option>
            <option value="Event">Event</option>
          </select>
          <div className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
            <svg
              className="w-4 h-4 text-[#565973]"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>
      </div>

      <PostList
        posts={posts}
        onLikePost={handleLikePost}
        onAddComment={handleAddComment}
        onLikeComment={handleLikeComment}
        currentUser={user}
      />
    </div>
  );
}
