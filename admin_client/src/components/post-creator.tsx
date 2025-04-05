"use client"

import type React from "react"

import { useState, useRef } from "react"
import { Button } from "@/components/ui/button"
import { UserAvatar } from "./user-avatar"
import { Image, MapPin, Smile, X, Tag } from "lucide-react"
import type { User } from "@/lib/types"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

interface PostCreatorProps {
  onCreatePost: (content: string, mediaUrls: string[], category?: string) => void
  currentUser: User
}

export default function PostCreator({ onCreatePost, currentUser }: PostCreatorProps) {
  const [content, setContent] = useState("")
  const [isExpanded, setIsExpanded] = useState(false)
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null)
  const [mediaUrls, setMediaUrls] = useState<string[]>([])
  const [activeTab, setActiveTab] = useState("post")
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFocus = () => {
    setIsExpanded(true)
  }

  const handleSubmit = () => {
    if (content.trim() || (activeTab === "photo" && mediaUrls.length > 0)) {
      onCreatePost(content, mediaUrls, selectedCategory || undefined)
      setContent("")
      setIsExpanded(false)
      setSelectedCategory(null)
      setMediaUrls([])
      setActiveTab("post")
    }
  }

  const handleFileSelect = () => {
    fileInputRef.current?.click()
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files
    if (files && files.length > 0) {
      // In a real app, you would upload the file to a server
      // For this demo, we'll just use a placeholder
      const newMediaUrls = Array.from(files).map(
        (_, index) => `/placeholder.svg?height=${300 + index * 50}&width=${400 + index * 50}`,
      )
      setMediaUrls([...mediaUrls, ...newMediaUrls])
    }
  }

  const removeMedia = (index: number) => {
    setMediaUrls(mediaUrls.filter((_, i) => i !== index))
  }

  const categories = [
    { id: "technology", name: "Technology" },
    { id: "design", name: "Design" },
    { id: "marketing", name: "Marketing" },
    { id: "business", name: "Business" },
    { id: "lifestyle", name: "Lifestyle" },
  ]

  return (
    <div className="bg-white rounded-xl p-4 shadow-sm transition-all">
      <Tabs defaultValue="post" className="w-full" onValueChange={setActiveTab}>
        <TabsList className="grid grid-cols-2 mb-4">
          <TabsTrigger value="post" className="data-[state=active]:bg-[#23c16b] data-[state=active]:text-white">
            Post
          </TabsTrigger>
          <TabsTrigger value="photo" className="data-[state=active]:bg-[#23c16b] data-[state=active]:text-white">
            Photo
          </TabsTrigger>
        </TabsList>

        <TabsContent value="post" className="mt-0">
          <div className="flex items-center gap-3">
            <UserAvatar user={currentUser} size="md" showStatus />
            <div
              className={`flex-1 bg-[#f0f2f5] rounded-full px-4 py-3 text-[#565973] cursor-text ${isExpanded ? "hidden" : "block"}`}
              onClick={handleFocus}
            >
              What's on your mind, {currentUser.name.split(" ")[0]}?
            </div>
            {isExpanded && (
              <div className="flex-1">
                <textarea
                  className="w-full bg-[#f0f2f5] rounded-lg px-4 py-3 text-[#0b0f19] placeholder-[#565973] focus:outline-none focus:ring-2 focus:ring-[#23c16b] resize-none min-h-[120px]"
                  placeholder={`What's on your mind, ${currentUser.name.split(" ")[0]}?`}
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  autoFocus
                />
              </div>
            )}
          </div>

          {isExpanded && mediaUrls.length > 0 && (
            <div className="mt-4 grid grid-cols-2 md:grid-cols-3 gap-2">
              {mediaUrls.map((src, index) => (
                <div key={index} className="relative rounded-lg overflow-hidden aspect-video bg-[#f0f2f5]">
                  <img src={src || "/placeholder.svg"} alt="Media" className="h-full w-full object-cover" />
                  <button
                    className="absolute top-2 right-2 bg-black/50 rounded-full p-1 hover:bg-black/70 transition-colors"
                    onClick={() => removeMedia(index)}
                  >
                    <X className="h-4 w-4 text-white" />
                  </button>
                </div>
              ))}
            </div>
          )}

          {isExpanded && (
            <div className="mt-4 p-3 bg-[#f0f2f5] rounded-lg flex items-center justify-between">
              <div className="text-sm font-medium text-[#0b0f19]">Add to your post</div>
              <div className="flex gap-2">
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-9 w-9 rounded-full hover:bg-[#e4e6eb]"
                  onClick={handleFileSelect}
                >
                  <Image className="h-5 w-5 text-[#f3425f]" />
                  <input
                    type="file"
                    ref={fileInputRef}
                    className="hidden"
                    accept="image/*"
                    multiple
                    onChange={handleFileChange}
                  />
                </Button>

                <Button variant="ghost" size="icon" className="h-9 w-9 rounded-full hover:bg-[#e4e6eb]">
                  <Smile className="h-5 w-5 text-[#f7b928]" />
                </Button>

                <Button variant="ghost" size="icon" className="h-9 w-9 rounded-full hover:bg-[#e4e6eb]">
                  <MapPin className="h-5 w-5 text-[#e94878]" />
                </Button>

                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button
                      variant="ghost"
                      size="icon"
                      className={`h-9 w-9 rounded-full hover:bg-[#e4e6eb] ${
                        selectedCategory ? "text-[#23c16b]" : "text-[#565973]"
                      }`}
                    >
                      <Tag className="h-5 w-5" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    {categories.map((category) => (
                      <DropdownMenuItem
                        key={category.id}
                        onClick={() => setSelectedCategory(category.id)}
                        className={selectedCategory === category.id ? "bg-[#d7fae0]" : ""}
                      >
                        {category.name}
                      </DropdownMenuItem>
                    ))}
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </div>
          )}

          <div className={`flex justify-end mt-4 ${isExpanded ? "flex-col gap-3" : ""}`}>
            {isExpanded && (
              <div className="flex gap-2 ml-auto">
                <Button
                  variant="outline"
                  className="rounded-lg text-[#565973] border-[#e4e6eb] hover:bg-[#f0f2f5]"
                  onClick={() => {
                    setIsExpanded(false)
                    setContent("")
                    setSelectedCategory(null)
                    setMediaUrls([])
                  }}
                >
                  Cancel
                </Button>

                <Button
                  className="rounded-lg bg-[#23c16b] hover:bg-[#23c16b]/90 text-white px-6"
                  onClick={handleSubmit}
                  disabled={!content.trim()}
                >
                  Post
                </Button>
              </div>
            )}
          </div>
        </TabsContent>

        <TabsContent value="photo" className="mt-0">
          <div className="flex items-center gap-3">
            <UserAvatar user={currentUser} size="md" showStatus />
            <div className="flex-1">
              <textarea
                className="w-full bg-[#f0f2f5] rounded-lg px-4 py-3 text-[#0b0f19] placeholder-[#565973] focus:outline-none focus:ring-2 focus:ring-[#23c16b] resize-none min-h-[80px]"
                placeholder="Share some photos with your friends"
                value={content}
                onChange={(e) => setContent(e.target.value)}
              />
            </div>
          </div>

          <div
            className="mt-4 border-2 border-dashed border-[#e4e6eb] rounded-lg p-8 text-center cursor-pointer"
            onClick={handleFileSelect}
          >
            <div className="flex flex-col items-center">
              <div className="h-12 w-12 rounded-full bg-[#f0f2f5] flex items-center justify-center mb-3">
                <Image className="h-6 w-6 text-[#565973]" />
              </div>
              <p className="text-[#0b0f19] font-medium">Add Photos</p>
              <p className="text-[#565973] text-sm mt-1">or drag and drop</p>
              <input
                type="file"
                ref={fileInputRef}
                className="hidden"
                accept="image/*"
                multiple
                onChange={handleFileChange}
              />
            </div>
          </div>

          {mediaUrls.length > 0 && (
            <div className="mt-4 grid grid-cols-2 md:grid-cols-3 gap-2">
              {mediaUrls.map((src, index) => (
                <div key={index} className="relative rounded-lg overflow-hidden aspect-video bg-[#f0f2f5]">
                  <img src={src || "/placeholder.svg"} alt="Media" className="h-full w-full object-cover" />
                  <button
                    className="absolute top-2 right-2 bg-black/50 rounded-full p-1 hover:bg-black/70 transition-colors"
                    onClick={() => removeMedia(index)}
                  >
                    <X className="h-4 w-4 text-white" />
                  </button>
                </div>
              ))}
            </div>
          )}

          <div className="flex justify-end mt-4">
            <Button
              className="rounded-lg bg-[#23c16b] hover:bg-[#23c16b]/90 text-white px-6"
              onClick={handleSubmit}
              disabled={mediaUrls.length === 0}
            >
              Post Photos
            </Button>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  )
}

