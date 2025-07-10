"use client"

import type React from "react"
import { useState, useEffect, useCallback } from "react"
import { useSearchParams } from "next/navigation"
import { ArrowUpDown, ArrowUp, ArrowDown, FileText, Trash2 } from "lucide-react"
import Image from "next/image"
import { Table, TableBody, TableCell, TableFooter, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Checkbox } from "@/components/ui/checkbox"
import { Button } from "@/components/ui/button"
import { Pagination } from "@/components/ui/pagination"
import { TooltipText } from "@/components/ui/tooltip-text"
import { TooltipProvider } from "@/components/ui/tooltip"
import type { Post } from "@/lib/types"
import { postService, type GetPostsParams } from "@/services/postService"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import { VisuallyHidden } from "@radix-ui/react-visually-hidden"
import PostItem from "./post-item"

// Resource Display Component
const ResourceDisplay = ({ resources }: { resources: Post["resources"] }) => {
  if (!resources || resources.length === 0) {
    return (
      <div className="flex items-center text-gray-400">
        <FileText className="h-4 w-4" />
        <span className="ml-1 text-xs">No resources</span>
      </div>
    )
  }

  const firstResource = resources[0]
  const isImage = firstResource.url?.match(/\.(jpg|jpeg|png|gif|webp)$/i)

  return (
    <div className="flex items-center gap-2">
      {isImage ? (
        <div className="h-8 w-8 rounded overflow-hidden border">
          <Image
            src={firstResource.url || "/placeholder.svg"}
            alt="Resource"
            width={32}
            height={32}
            className="object-cover w-full h-full"
          />
        </div>
      ) : (
        <div className="h-8 w-8 rounded bg-gray-100 flex items-center justify-center">
          <FileText className="h-4 w-4 text-gray-600" />
        </div>
      )}
      {resources.length > 1 && <span className="text-xs text-gray-500">+{resources.length - 1} more</span>}
    </div>
  )
}

export function PostTable() {
  const searchParams = useSearchParams()
  const [sortColumn, setSortColumn] = useState<"createdAt" | "reportsCount" | "">("")
  const [sortDirection, setSortDirection] = useState<"desc" | "asc">("desc")
  const [selectedRows, setSelectedRows] = useState<Record<string, boolean>>({})
  const [selectAll, setSelectAll] = useState(false)
  const [selectedPost, setSelectedPost] = useState<Post | null>(null)
  const [searchQuery, setSearchQuery] = useState(searchParams.get("q") || "")

  // API state
  const [posts, setPosts] = useState<Post[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage, setItemsPerPage] = useState(10)
  const [totalPages, setTotalPages] = useState(0)
  const [totalItems, setTotalItems] = useState(0)

  // Update search query when URL params change
  useEffect(() => {
    setSearchQuery(searchParams.get("q") || "")
  }, [searchParams])

  // Reset to page 1 when search query changes
  useEffect(() => {
    if (searchQuery !== searchParams.get("q")) {
      setCurrentPage(1)
    }
  }, [searchQuery, searchParams])

  // Fetch posts function
  const fetchPosts = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const params: GetPostsParams = {
        pageNumber: currentPage,
        pageSize: itemsPerPage,
        sortBy: sortDirection,
        orderBy: sortColumn || "createdAt", // Default to createdAt
        search: searchQuery.trim() || undefined, // Add search parameter
      }

      console.log("Fetching posts with params:", params)
      const response = await postService.getPosts(params)
      console.log("API Response:", response)

      // Handle different response structures
      if (Array.isArray(response)) {
        // If response is directly an array
        setPosts(response)
        setTotalPages(Math.ceil(response.length / itemsPerPage))
        setTotalItems(response.length)
      } else if (response && typeof response === "object") {
        // If response is an object with items
        // Use type guard to check for 'data' property
        type ResponseWithData = { data: Post[] }
        const items =
          response.items ||
          (typeof response === "object" && response !== null && "data" in response
            ? (response as ResponseWithData).data
            : undefined) ||
          response
        const posts = Array.isArray(items) ? items : Array.isArray(response) ? response : []

        setPosts(posts)
        setTotalPages(response.totalPages || Math.ceil(posts.length / itemsPerPage) || 1)
        setTotalItems(
          response.totalCount ||
            (typeof response === "object" && response !== null && "total" in response && typeof (response as { total: unknown }).total === "number"
              ? (response as { total: number }).total
              : posts.length)
        )

        console.log("Processed data:", {
          postsCount: posts.length,
          totalPages: response.totalPages || Math.ceil(posts.length / itemsPerPage),
          totalItems: response.totalCount || posts.length,
        })
      } else {
        console.warn("Unexpected response format:", response)
        setPosts([])
        setTotalPages(0)
        setTotalItems(0)
      }
    } catch (err) {
      console.error("Failed to fetch posts:", err)
      setError(`Failed to load posts: ${err instanceof Error ? err.message : "Unknown error"}`)
      setPosts([])
      setTotalPages(0)
      setTotalItems(0)
    } finally {
      setLoading(false)
    }
  }, [currentPage, itemsPerPage, sortColumn, sortDirection, searchQuery])

  const handleDeletePost = async (postId: string) => {
    try {
      await postService.deletePost(postId)
      // Refresh the posts list
      await fetchPosts()
      // Close modal if the deleted post was being viewed
      if (selectedPost?.id === postId) {
        setSelectedPost(null)
      }
    } catch (err) {
      console.error("Failed to delete post:", err)
      setError(`Failed to delete post: ${err instanceof Error ? err.message : "Unknown error"}`)
    }
  }

  const handleRowClick = (post: Post) => {
    setSelectedPost(post)
  }

  // Fetch data when filters, pagination, or sorting changes
  useEffect(() => {
    fetchPosts()
  }, [fetchPosts])

  const handleSort = (column: "createdAt" | "reportsCount") => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === "desc" ? "asc" : "desc")
    } else {
      setSortColumn(column)
      setSortDirection("desc")
    }
  }

  const handleSelectAll = () => {
    const newSelectAll = !selectAll
    setSelectAll(newSelectAll)

    const newSelectedRows: Record<string, boolean> = {}
    if (newSelectAll) {
      posts.forEach((post) => {
        newSelectedRows[post.id] = true
      })
    }
    setSelectedRows(newSelectedRows)
  }

  const handleSelectRow = (postId: string, checked: boolean, event: React.MouseEvent) => {
    event.stopPropagation()

    setSelectedRows((prev) => ({
      ...prev,
      [postId]: checked,
    }))

    const allSelected = Object.keys(selectedRows).length === posts.length - 1 && checked
    setSelectAll(allSelected)
  }

  const handlePageChange = (page: number) => {
    setCurrentPage(page)
  }

  const handleItemsPerPageChange = (value: string) => {
    const newItemsPerPage = Number(value)
    setItemsPerPage(newItemsPerPage)
    setCurrentPage(1)
  }

  const getSortIcon = (column: "createdAt" | "reportsCount") => {
    if (sortColumn !== column) return <ArrowUpDown className="ml-2 h-4 w-4" />
    return sortDirection === "desc" ? <ArrowUp className="ml-2 h-4 w-4" /> : <ArrowDown className="ml-2 h-4 w-4" />
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  const selectedCount = Object.values(selectedRows).filter(Boolean).length

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64 bg-white">
        <div className="text-center bg-white p-8 rounded-lg">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Loading posts...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64 bg-white">
        <div className="text-center bg-white p-8 rounded-lg">
          <p className="text-red-600 mb-4">{error}</p>
          <Button onClick={fetchPosts} variant="outline" className="bg-white border border-gray-300">
            Try Again
          </Button>
        </div>
      </div>
    )
  }

  return (
    <TooltipProvider>
      <div className="space-y-4 bg-white p-4">
        <div className="flex items-center justify-between bg-white">
          <div className="flex items-center space-x-4 bg-white">
            <h2 className="text-xl font-semibold text-gray-800">Post Management</h2>
            {searchQuery && (
              <div className="text-sm text-gray-600">
                Search results for: <span className="font-medium">&quot;{searchQuery}&quot;</span>
              </div>
            )}
          </div>

          {selectedCount > 0 && (
            <div className="bg-green-600 text-white px-4 py-2 rounded-full text-sm font-medium">
              {selectedCount} {selectedCount === 1 ? "post" : "posts"} selected
            </div>
          )}
        </div>

        <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="bg-gray-50 hover:bg-gray-100">
                  <TableHead className="w-[60px] rounded-tl-xl bg-gray-50">No</TableHead>
                  <TableHead className="w-[250px] bg-gray-50">
                    <div className="flex items-center">Publisher Name</div>
                  </TableHead>
                  <TableHead className="w-[350px] bg-gray-50">
                    <div className="flex items-center">Post Title</div>
                  </TableHead>
                  <TableHead className="w-[150px] cursor-pointer bg-gray-50" onClick={() => handleSort("createdAt")}>
                    <div className="flex items-center">
                      Created At
                      {getSortIcon("createdAt")}
                    </div>
                  </TableHead>
                  <TableHead className="w-[120px] bg-gray-50">
                    <div className="flex items-center">Likes Count</div>
                  </TableHead>
                  <TableHead className="w-[120px] bg-gray-50">
                    <div className="flex items-center">Comments Count</div>
                  </TableHead>
                  <TableHead className="w-[120px] cursor-pointer bg-gray-50" onClick={() => handleSort("reportsCount")}>
                    <div className="flex items-center">
                      Reports Count
                      {getSortIcon("reportsCount")}
                    </div>
                  </TableHead>
                  <TableHead className="w-[100px] rounded-tr-xl bg-gray-50">
                    <div className="flex items-center cursor-pointer" onClick={handleSelectAll}>
                      {selectAll ? "Unselect All" : "Select All"}
                    </div>
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody className="bg-white">
                {posts && posts.length > 0 ? (
                  posts.map((post, index) => (
                    <TableRow
                      key={post.id}
                      className={`${
                        selectedRows[post.id] ? "bg-green-50" : "bg-white"
                      } hover:bg-gray-50 transition-colors cursor-pointer`}
                      onClick={() => handleRowClick(post)}
                    >
                      <TableCell className="font-medium bg-white">
                        {(currentPage - 1) * itemsPerPage + index + 1}
                      </TableCell>
                      <TableCell className="w-[250px] bg-white">
                        <div className="flex items-center gap-3">
                          <div className="h-10 w-10 rounded-full overflow-hidden shadow-sm border flex-shrink-0 bg-white">
                            <Image
                              src={post.publisherImageUrl || "/placeholder.svg?height=40&width=40"}
                              alt={post.publisherUsername}
                              width={40}
                              height={40}
                              className="object-cover w-full h-full"
                            />
                          </div>
                          <div className="flex-1 min-w-0 bg-white">
                            <div className="font-medium text-gray-900 truncate">
                              <TooltipText text={post.publisherUsername} maxLength={20} />
                            </div>
                            <div className="text-xs text-muted-foreground">ID: {post.publisherId.slice(0, 8)}...</div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell className="w-[350px] bg-white">
                        <div className="space-y-2">
                          <div className="flex items-start gap-2">
                            <ResourceDisplay resources={post.resources} />
                            <div className="flex-1 min-w-0">
                              <div className="font-medium text-gray-900 truncate">
                                <TooltipText text={post.title} maxLength={30} />
                              </div>
                              <div className="text-xs text-muted-foreground truncate">
                                <TooltipText text={post.content} maxLength={50} />
                              </div>
                            </div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell className="w-[150px] bg-white">
                        <div className="text-sm">{formatDate(post.createdAt)}</div>
                      </TableCell>
                      <TableCell className="w-[120px] bg-white text-center">
                        <div className="flex items-center justify-center gap-1">
                          <span className="font-medium">{post.likesCount}</span>
                          {post.isLiked && <span className="text-red-500 text-xs">❤️</span>}
                        </div>
                      </TableCell>
                      <TableCell className="w-[120px] bg-white text-center">
                        <span className="font-medium">{post.commentsCount}</span>
                      </TableCell>
                      <TableCell className="w-[120px] bg-white text-center">
                        <div className="flex items-center justify-center gap-1">
                          <span className={`font-medium ${post.reportsCount > 0 ? "text-red-600" : "text-gray-600"}`}>
                            {post.reportsCount}
                          </span>
                          {post.isReported && <span className="text-red-500 text-xs">🚨</span>}
                        </div>
                      </TableCell>
                      <TableCell
                        className="w-[100px] text-center bg-white"
                        onClick={(e) => {
                          e.stopPropagation()
                        }}
                      >
                        <Checkbox
                          checked={selectedRows[post.id] || false}
                          onCheckedChange={(checked) => {
                            const syntheticEvent = {
                              stopPropagation: () => {},
                            } as React.MouseEvent
                            handleSelectRow(post.id, checked as boolean, syntheticEvent)
                          }}
                          aria-label={`Select ${post.title}`}
                          className="data-[state=checked]:bg-green-600 data-[state=checked]:border-green-600 bg-white border border-gray-300"
                        />
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow className="bg-white">
                    <TableCell colSpan={8} className="text-center py-8 text-gray-500 bg-white">
                      <div className="flex flex-col items-center gap-2">
                        {searchQuery ? (
                          <>
                            <p>No posts found for &quot;{searchQuery}&quot;</p>
                            <p className="text-sm text-gray-400">Try adjusting your search terms</p>
                          </>
                        ) : (
                          <>
                            <p>No posts found</p>
                            <p className="text-sm text-gray-400">No data available</p>
                          </>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
              <TableFooter className="bg-white">
                <TableRow className="bg-white">
                  <TableCell colSpan={8} className="rounded-b-xl p-0 bg-white">
                    <Pagination
                      currentPage={currentPage}
                      totalPages={totalPages}
                      totalItems={totalItems}
                      itemsPerPage={itemsPerPage}
                      startIndex={(currentPage - 1) * itemsPerPage}
                      onPageChange={handlePageChange}
                      onItemsPerPageChange={handleItemsPerPageChange}
                    />
                  </TableCell>
                </TableRow>
              </TableFooter>
            </Table>
          </div>
        </div>
      </div>
      {selectedPost && (
        <Dialog open={!!selectedPost} onOpenChange={(open) => !open && setSelectedPost(null)}>
          <DialogContent className="max-w-4xl max-h-[90vh] p-0 overflow-hidden">
            <VisuallyHidden>
              <DialogTitle>Post Details</DialogTitle>
            </VisuallyHidden>
            <div className="relative h-full">
              <div className="absolute top-4 right-4 z-10 flex gap-2">
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={() => handleDeletePost(selectedPost.id)}
                  className="bg-red-600 hover:bg-red-700 shadow-lg"
                >
                  <Trash2 className="h-4 w-4 mr-1" />
                  Delete
                </Button>
              </div>
              {/* Custom scrollable container with hidden scrollbar */}
              <div
                className="h-[90vh] overflow-y-auto scrollbar-hide"
                style={{
                  scrollbarWidth: "none" /* Firefox */,
                  msOverflowStyle: "none" /* Internet Explorer 10+ */,
                }}
              >
                <style jsx>{`
                  .scrollbar-hide::-webkit-scrollbar {
                    display: none; /* Safari and Chrome */
                  }
                `}</style>
                <PostItem post={selectedPost} currentUser={{}} />
              </div>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </TooltipProvider>
  )
}
