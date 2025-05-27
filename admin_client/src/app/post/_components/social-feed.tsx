"use client"

import { useState, useEffect } from "react"
import PostCreator from "./post-creator"
import PostList from "./post-list"
import type { Post, Comment } from "@/lib/types"
import { useAuth } from "@/hooks/use-auth"
import { postService } from "@/services/postService"
import { commentService } from "@/services/commentService"
import { getApiInfo, checkApiConnection, setUseMockData } from "@/services/api"
import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert"
import { Button } from "@/components/ui/button"
import { RefreshCw, Database } from "lucide-react"

export default function SocialFeed() {
  const [posts, setPosts] = useState<Post[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [apiStatus, setApiStatus] = useState<"checking" | "connected" | "disconnected">("checking")
  const [useMockData, setUseMockDataState] = useState(false)
  const { user } = useAuth()
  const [isCreatingPost, setIsCreatingPost] = useState(false)

  // Kiểm tra kết nối API khi component mount
  useEffect(() => {
    const checkConnection = async () => {
      try {
        const isConnected = await checkApiConnection()
        setApiStatus(isConnected ? "connected" : "disconnected")

        // Nếu không kết nối được, hiển thị thông báo
        if (!isConnected) {
          console.warn("Could not connect to API server. You can enable mock data mode.")
        }
      } catch (error) {
        console.error("Error checking API connection:", error)
        setApiStatus("disconnected")
      }
    }

    checkConnection()
  }, [])

  // Fetch posts on component mount or when apiStatus changes
  useEffect(() => {
    const fetchPosts = async () => {
      try {
        setLoading(true)

        // Kiểm tra thông tin API
        const { apiUrl, isConfigured } = getApiInfo()

        if (!isConfigured && !useMockData) {
          setError(
            "API URL is not configured. Please set the NEXT_PUBLIC_API_URL environment variable or enable mock data mode.",
          )
          setLoading(false)
          return
        }

        console.log(`Fetching posts from: ${useMockData ? "mock data" : apiUrl}`)
        const fetchedPosts = await postService.getPosts()
        setPosts(fetchedPosts)
      } catch (err) {
        console.error("Failed to fetch posts:", err)

        // Hiển thị thông báo lỗi chi tiết hơn
        if (err instanceof Error) {
          if (err.message.includes("Network error")) {
            setError(
              "Could not connect to the API server. Please check your network connection and server status or enable mock data mode.",
            )
          } else {
            setError(`Failed to load posts: ${err.message}`)
          }
        } else {
          setError("Failed to load posts. Please try again later.")
        }
      } finally {
        setLoading(false)
      }
    }

    if (apiStatus === "connected" || useMockData) {
      fetchPosts()
    }
  }, [apiStatus, useMockData])

  const handleCreatePost = async (content: string, files: File[] = [], category?: string) => {
    try {
      setIsCreatingPost(true)
      console.log("Creating post, isCreatingPost set to true")

      // Thêm độ trễ giả lập để kiểm tra loading indicator
      await new Promise((resolve) => setTimeout(resolve, 2000))

      const newPostData = {
        title: content.split(" ").slice(0, 7).join(" ") + (content.split(" ").length > 7 ? "..." : ""),
        content,
        category: category || "Sharing",
        resources: files,
      }

      const newPost = await postService.createPost(newPostData)
      setPosts([newPost, ...posts])
      return Promise.resolve()
    } catch (err) {
      console.error("Failed to create post:", err)
      // You could add a toast notification here
      return Promise.reject(err)
    } finally {
      setIsCreatingPost(false)
      console.log("Post creation completed, isCreatingPost set to false")
    }
  }

  const handleLikePost = async (postId: string) => {
    try {
      await postService.toggleLikePost(postId)

      // Update UI optimistically
      setPosts(
        posts.map((post) => {
          if (post.id === postId) {
            const newIsLiked = !post.isLiked
            return {
              ...post,
              likesCount: newIsLiked ? post.likesCount + 1 : post.likesCount - 1,
              isLiked: newIsLiked,
            }
          }
          return post
        }),
      )
    } catch (err) {
      console.error("Failed to like post:", err)
      // Revert the optimistic update if the API call fails
    }
  }

  const handleAddComment = async (postId: string, content: string): Promise<Comment> => {
    try {
      const newComment = await commentService.createComment({
        postId,
        content,
      })

      // Update the post with the new comment
      setPosts(
        posts.map((post) => {
          if (post.id === postId) {
            return {
              ...post,
              commentsCount: post.commentsCount + 1,
              // If we need to show comments immediately, we would need to fetch them
            }
          }
          return post
        }),
      )

      return newComment
    } catch (err) {
      console.error("Failed to add comment:", err)
      throw err
    }
  }

  const handleLikeComment = async (commentId: string) => {
    try {
      await commentService.toggleLikeComment(commentId)

      // Since we don't have the comments in the posts state,
      // we would need to fetch them again or update the UI optimistically
      // This would depend on how you're managing comments state
    } catch (err) {
      console.error("Failed to like comment:", err)
    }
  }

  const handleRetry = () => {
    setError(null)
    setApiStatus("checking")
    checkApiConnection().then((isConnected) => {
      setApiStatus(isConnected ? "connected" : "disconnected")
    })
  }

  const toggleMockData = () => {
    const newMockDataState = !useMockData
    setUseMockDataState(newMockDataState)
    setUseMockData(newMockDataState) // Update the global state in api.ts

    if (newMockDataState) {
      setApiStatus("connected") // Treat as connected when using mock data
      setError(null) // Clear any existing errors
    } else if (apiStatus === "disconnected") {
      // If turning off mock data and API is disconnected, we need to check again
      handleRetry()
    }
  }

  if (apiStatus === "checking" && !useMockData) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-8">
        <div className="flex flex-col items-center justify-center space-y-4">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-500"></div>
          <p className="text-gray-600">Checking API connection...</p>
        </div>
      </div>
    )
  }

  if (apiStatus === "disconnected" && !useMockData) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-8">
        <Alert variant="destructive" className="mb-4">
          <AlertTitle>API Connection Error</AlertTitle>
          <AlertDescription>
            Could not connect to the API server. Please check your network connection and server status.
            <div className="mt-4">
              <p className="text-sm text-gray-500">API URL: {getApiInfo().apiUrl}</p>
              <p className="text-sm text-gray-500">
                {getApiInfo().isConfigured
                  ? "Environment variable NEXT_PUBLIC_API_URL is configured."
                  : "Environment variable NEXT_PUBLIC_API_URL is not configured."}
              </p>
            </div>
          </AlertDescription>
        </Alert>
        <div className="flex gap-4 mt-4">
          <Button onClick={handleRetry} className="flex-1">
            <RefreshCw className="mr-2 h-4 w-4" /> Retry Connection
          </Button>
          <Button onClick={toggleMockData} variant="outline" className="flex-1">
            <Database className="mr-2 h-4 w-4" /> Use Mock Data
          </Button>
        </div>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-8">
        <div className="animate-pulse space-y-4">
          <div className="h-32 bg-gray-200 rounded-xl"></div>
          <div className="h-64 bg-gray-200 rounded-xl"></div>
          <div className="h-64 bg-gray-200 rounded-xl"></div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-8">
        <Alert variant="destructive" className="mb-4">
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>{error}</AlertDescription>
        </Alert>
        <div className="flex gap-4 mt-4">
          <Button onClick={handleRetry} className="flex-1">
            <RefreshCw className="mr-2 h-4 w-4" /> Try Again
          </Button>
          <Button onClick={toggleMockData} variant="outline" className="flex-1">
            <Database className="mr-2 h-4 w-4" /> {useMockData ? "Disable" : "Enable"} Mock Data
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-2xl mx-auto px-4 space-y-6">
      {useMockData && (
        <Alert className="bg-yellow-50 border-yellow-200">
          <AlertTitle className="text-yellow-800">Using Mock Data</AlertTitle>
          <AlertDescription className="text-yellow-700">
            You are currently using mock data. API requests will not be sent to the server.
            <Button onClick={toggleMockData} variant="outline" className="mt-2 border-yellow-300 text-yellow-800">
              <Database className="mr-2 h-4 w-4" /> Disable Mock Data
            </Button>
          </AlertDescription>
        </Alert>
      )}

      {user && <PostCreator onCreatePost={handleCreatePost} currentUser={user} isCreatingPost={isCreatingPost} />}

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
  )
}
