"use client"

import { useState } from "react"
import PostCreator from "./post-creator"
import PostList from "./post-list"
import type { Post, Comment, User } from "@/lib/types"
import { users, initialPosts } from "@/lib/data"

export default function SocialNetworkFeed() {
  const [posts, setPosts] = useState<Post[]>(initialPosts)
  const [currentUser] = useState<User>(users[0])

  const handleCreatePost = (content: string, category?: string) => {
    const newPost: Post = {
      id: `post-${Date.now()}`,
      author: currentUser,
      content,
      title: content.split(" ").slice(0, 7).join(" ") + (content.split(" ").length > 7 ? "..." : ""),
      category: category || "General",
      likes: 0,
      comments: [],
      createdAt: new Date(),
      isLiked: false,
    }

    setPosts([newPost, ...posts])
  }

  const handleLikePost = (postId: string) => {
    setPosts(
      posts.map((post) => {
        if (post.id === postId) {
          return {
            ...post,
            likes: post.isLiked ? post.likes - 1 : post.likes + 1,
            isLiked: !post.isLiked,
          }
        }
        return post
      }),
    )
  }

  const handleAddComment = (postId: string, content: string) => {
    setPosts(
      posts.map((post) => {
        if (post.id === postId) {
          const newComment: Comment = {
            id: `comment-${Date.now()}`,
            author: currentUser,
            content,
            createdAt: new Date(),
            likes: 0,
            isLiked: false,
          }

          return {
            ...post,
            comments: [...post.comments, newComment],
          }
        }
        return post
      }),
    )
  }

  const handleLikeComment = (postId: string, commentId: string) => {
    setPosts(
      posts.map((post) => {
        if (post.id === postId) {
          const updatedComments = post.comments.map((comment) => {
            if (comment.id === commentId) {
              return {
                ...comment,
                likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
                isLiked: !comment.isLiked,
              }
            }
            return comment
          })

          return {
            ...post,
            comments: updatedComments,
          }
        }
        return post
      }),
    )
  }

  return (
    <div className="max-w-2xl mx-auto py-6 px-4 space-y-6">
      <PostCreator onCreatePost={handleCreatePost} currentUser={currentUser} />

      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-[#0b0f19]">Bài viết gần đây</h2>
        <div className="relative">
          <select
            className="appearance-none bg-[#d7fae0] text-[#565973] py-1 px-4 pr-8 rounded-full border-none focus:outline-none focus:ring-2 focus:ring-[#23c16b]"
            defaultValue="all"
          >
            <option value="all">Tất cả</option>
            <option value="admissions">Tuyển sinh</option>
            <option value="events">Sự kiện</option>
            <option value="news">Tin tức</option>
          </select>
          <div className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
            <svg
              className="w-4 h-4 text-[#23c16b]"
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
        currentUser={currentUser}
      />
    </div>
  )
}

