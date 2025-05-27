"use client"

import type React from "react"
import { useState, useRef, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { UserAvatar } from "./user-avatar"
import { ImageIcon, Smile, X, Tag, Loader2 } from "lucide-react"
import type { User } from "@/lib/types"
import Image from "next/image"
import dynamic from "next/dynamic"
import type { EmojiClickData } from "emoji-picker-react"

import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

// Dynamically import the emoji picker to reduce initial load time
const EmojiPicker = dynamic(() => import("emoji-picker-react"), {
  ssr: false,
  loading: () => (
    <div className="p-4 flex justify-center">
      <Loader2 className="h-6 w-6 animate-spin text-[#23c16b]" />
    </div>
  ),
})

interface PostCreatorProps {
  onCreatePost: (content: string, files: File[], category?: string) => Promise<void>
  currentUser: Partial<User>
  isCreatingPost?: boolean
}

export default function PostCreator({ onCreatePost, currentUser, isCreatingPost = false }: PostCreatorProps) {
  const [content, setContent] = useState("")
  const [isExpanded, setIsExpanded] = useState(false)
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null)
  const [files, setFiles] = useState<File[]>([])
  const [previews, setPreviews] = useState<string[]>([])
  const [activeTab, setActiveTab] = useState("post")
  const [showEmojiPicker, setShowEmojiPicker] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const emojiPickerRef = useRef<HTMLDivElement>(null)
  const emojiButtonRef = useRef<HTMLButtonElement>(null)

  const handleFocus = () => {
    setIsExpanded(true)
  }

  // Close emoji picker when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        emojiPickerRef.current &&
        !emojiPickerRef.current.contains(event.target as Node) &&
        emojiButtonRef.current &&
        !emojiButtonRef.current.contains(event.target as Node)
      ) {
        setShowEmojiPicker(false)
      }
    }

    document.addEventListener("mousedown", handleClickOutside)
    return () => {
      document.removeEventListener("mousedown", handleClickOutside)
    }
  }, [])

  const handleSubmit = async () => {
    if (!isCreatingPost && (content.trim() || (activeTab === "photo" && files.length > 0))) {
      try {
        // Không reset state ngay lập tức, đợi cho đến khi quá trình tạo post hoàn tất
        await onCreatePost(content, files, selectedCategory || undefined)

        // Chỉ reset state sau khi quá trình tạo post hoàn tất thành công
        setContent("")
        setIsExpanded(false)
        setSelectedCategory(null)
        setFiles([])
        setPreviews([])
        setActiveTab("post")
      } catch (error) {
        console.error("Error creating post:", error)
        // Không reset state nếu có lỗi, để người dùng có thể thử lại
      }
    }
  }

  const handleFileSelect = () => {
    fileInputRef.current?.click()
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFiles = e.target.files
    if (selectedFiles && selectedFiles.length > 0) {
      const newFiles = Array.from(selectedFiles)
      setFiles([...files, ...newFiles])

      // Create previews for the files
      const newPreviews = Array.from(selectedFiles).map((file) => URL.createObjectURL(file))
      setPreviews([...previews, ...newPreviews])
    }
  }

  const removeFile = (index: number) => {
    const newFiles = [...files]
    newFiles.splice(index, 1)
    setFiles(newFiles)

    const newPreviews = [...previews]
    URL.revokeObjectURL(newPreviews[index]) // Clean up the URL
    newPreviews.splice(index, 1)
    setPreviews(newPreviews)
  }

  const handleEmojiClick = (emojiData: EmojiClickData) => {
    const emoji = emojiData.emoji
    const cursorPosition = textareaRef.current?.selectionStart || content.length
    const newContent = content.slice(0, cursorPosition) + emoji + content.slice(cursorPosition)
    setContent(newContent)

    // Focus back on textarea after emoji selection
    setTimeout(() => {
      if (textareaRef.current) {
        textareaRef.current.focus()
        textareaRef.current.selectionStart = cursorPosition + emoji.length
        textareaRef.current.selectionEnd = cursorPosition + emoji.length
      }
    }, 10)
  }

  const toggleEmojiPicker = () => {
    setShowEmojiPicker((prev) => !prev)
  }

  const categories = [
    { id: "Sharing", name: "Sharing" },
    { id: "Question", name: "Question" },
    { id: "News", name: "News" },
    { id: "Event", name: "Event" },
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
              className={`flex-1 bg-[#f0f2f5] rounded-full px-4 py-3 text-[#565973] cursor-text ${
                isExpanded ? "hidden" : "block"
              }`}
              onClick={handleFocus}
            >
              What on your mind, {currentUser.username?.split(" ")[0] || "there"}?
            </div>
            {isExpanded && (
              <div className="flex-1">
                <textarea
                  ref={textareaRef}
                  className="w-full bg-[#f0f2f5] rounded-lg px-4 py-3 text-[#0b0f19] placeholder-[#565973] focus:outline-none focus:ring-2 focus:ring-[#23c16b] resize-none min-h-[120px]"
                  placeholder={`What's on your mind, ${currentUser.username?.split(" ")[0] || "there"}?`}
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  autoFocus
                  disabled={isCreatingPost}
                />
              </div>
            )}
          </div>

          {isExpanded && previews.length > 0 && (
            <div className="mt-4 grid grid-cols-2 md:grid-cols-3 gap-2">
              {previews.map((src, index) => (
                <div key={index} className="relative rounded-lg overflow-hidden aspect-video bg-[#f0f2f5]">
                  <div className="relative h-full w-full">
                    <Image src={src || "/placeholder.svg"} alt="Media" fill className="object-cover" sizes="100vw" />
                  </div>
                  <button
                    className="absolute top-2 right-2 bg-black/50 rounded-full p-1 hover:bg-black/70 transition-colors"
                    onClick={() => removeFile(index)}
                    disabled={isCreatingPost}
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
                  disabled={isCreatingPost}
                >
                  <ImageIcon className="h-5 w-5 text-[#f3425f]" />
                  <input
                    type="file"
                    ref={fileInputRef}
                    className="hidden"
                    accept="image/*"
                    multiple
                    onChange={handleFileChange}
                    disabled={isCreatingPost}
                  />
                </Button>

                <div className="relative">
                  <Button
                    ref={emojiButtonRef}
                    variant="ghost"
                    size="icon"
                    className="h-9 w-9 rounded-full hover:bg-[#e4e6eb]"
                    onClick={toggleEmojiPicker}
                    disabled={isCreatingPost}
                  >
                    <Smile className="h-5 w-5 text-[#f7b928]" />
                  </Button>

                  {showEmojiPicker && (
                    <div className="absolute right-0 z-50" style={{ top: "calc(100% + 8px)" }} ref={emojiPickerRef}>
                      <div className="shadow-lg rounded-lg overflow-hidden">
                        <EmojiPicker
                          onEmojiClick={handleEmojiClick}
                          width={320}
                          height={350}
                          previewConfig={{ showPreview: false }}
                        />
                      </div>
                    </div>
                  )}
                </div>

                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button
                      variant="ghost"
                      size="icon"
                      className={`h-9 w-9 rounded-full hover:bg-[#e4e6eb] ${
                        selectedCategory ? "text-[#23c16b]" : "text-[#565973]"
                      }`}
                      disabled={isCreatingPost}
                    >
                      <Tag className="h-5 w-5" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    {categories.map((category) => (
                      <DropdownMenuItem
                        key={category.id}
                        onClick={() => !isCreatingPost && setSelectedCategory(category.id)}
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
                    setFiles([])
                    setPreviews([])
                  }}
                  disabled={isCreatingPost}
                >
                  Cancel
                </Button>

                <Button
                  className="rounded-lg bg-[#23c16b] hover:bg-[#23c16b]/90 text-white px-6"
                  onClick={handleSubmit}
                  disabled={(!content.trim() && files.length === 0) || isCreatingPost}
                >
                  {isCreatingPost ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Posting...
                    </>
                  ) : (
                    "Post"
                  )}
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
                disabled={isCreatingPost}
              />
            </div>
          </div>

          <div
            className={`mt-4 border-2 border-dashed border-[#e4e6eb] rounded-lg p-8 text-center ${
              isCreatingPost ? "cursor-not-allowed opacity-50" : "cursor-pointer"
            }`}
            onClick={isCreatingPost ? undefined : handleFileSelect}
          >
            <div className="flex flex-col items-center">
              <div className="h-12 w-12 rounded-full bg-[#f0f2f5] flex items-center justify-center mb-3">
                <ImageIcon className="h-6 w-6 text-[#565973]" />
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
                disabled={isCreatingPost}
              />
            </div>
          </div>

          {previews.length > 0 && (
            <div className="mt-4 grid grid-cols-2 md:grid-cols-3 gap-2">
              {previews.map((src, index) => (
                <div key={index} className="relative rounded-lg overflow-hidden aspect-video bg-[#f0f2f5]">
                  <div className="relative h-full w-full">
                    <Image src={src || "/placeholder.svg"} alt="Media" fill className="object-cover" sizes="100vw" />
                  </div>

                  <button
                    className="absolute top-2 right-2 bg-black/50 rounded-full p-1 hover:bg-black/70 transition-colors"
                    onClick={() => removeFile(index)}
                    disabled={isCreatingPost}
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
              disabled={files.length === 0 || isCreatingPost}
            >
              {isCreatingPost ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Posting...
                </>
              ) : (
                "Post Photos"
              )}
            </Button>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  )
}
