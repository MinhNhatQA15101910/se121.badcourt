"use client"

import type React from "react"
import { useState, useEffect, useRef } from "react"
import { Button } from "@/components/ui/button"
import { Smile, ImageIcon, Send, X, Loader2 } from 'lucide-react'
import ImageViewer from "./image-viewer2"
import dynamic from "next/dynamic"
import type { EmojiClickData } from "emoji-picker-react"

// Dynamically import the emoji picker to reduce initial load time
const EmojiPicker = dynamic(() => import("emoji-picker-react"), { 
  ssr: false,
  loading: () => <div className="p-4 flex justify-center"><Loader2 className="h-6 w-6 animate-spin text-[#23c16b]" /></div>
})

interface CommentInputProps {
  onAddComment: (content: string, files?: File[]) => Promise<void>
  isFocused: boolean
  onFocusChange: (isFocused: boolean) => void
  inputRef?: React.RefObject<HTMLInputElement | null>
}

export default function CommentInput({ onAddComment, isFocused, onFocusChange, inputRef }: CommentInputProps) {
  const [content, setContent] = useState("")
  const [selectedFiles, setSelectedFiles] = useState<File[]>([])
  const [previewUrls, setPreviewUrls] = useState<string[]>([])
  const [isImageViewerOpen, setIsImageViewerOpen] = useState(false)
  const [currentImageIndex, setCurrentImageIndex] = useState(0)
  const [imageLoadError, setImageLoadError] = useState<Record<string, boolean>>({})
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [showEmojiPicker, setShowEmojiPicker] = useState(false)
  const localInputRef = useRef<HTMLInputElement>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const emojiPickerRef = useRef<HTMLDivElement>(null)
  const actualInputRef = inputRef || localInputRef

  useEffect(() => {
    if (isFocused && actualInputRef.current) {
      actualInputRef.current.focus()
    }
  }, [isFocused, actualInputRef])

  // Clean up preview URLs when component unmounts
  useEffect(() => {
    return () => {
      previewUrls.forEach((url) => URL.revokeObjectURL(url))
    }
  }, [previewUrls])

  // Close emoji picker when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        emojiPickerRef.current && 
        !emojiPickerRef.current.contains(event.target as Node) &&
        !(event.target as Element).closest('.emoji-toggle-button')
      ) {
        setShowEmojiPicker(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [])

  const handleSubmit = async () => {
    if ((content.trim() || selectedFiles.length > 0) && !isSubmitting) {
      try {
        setIsSubmitting(true)
        await onAddComment(content, selectedFiles.length > 0 ? selectedFiles : undefined)
        setContent("")

        // Clean up preview URLs
        previewUrls.forEach((url) => URL.revokeObjectURL(url))
        setPreviewUrls([])
        setSelectedFiles([])
        setImageLoadError({})

        // Reset file input
        if (fileInputRef.current) {
          fileInputRef.current.value = ""
        }
      } catch (error) {
        console.error("Error submitting comment:", error)
      } finally {
        setIsSubmitting(false)
      }
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" && !e.shiftKey && !isSubmitting) {
      e.preventDefault()
      handleSubmit()
    }
  }

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      const files = Array.from(e.target.files)

      // Clean up old preview URLs
      previewUrls.forEach((url) => URL.revokeObjectURL(url))

      // Create new preview URLs
      const newPreviewUrls = files.map((file) => URL.createObjectURL(file))

      setSelectedFiles(files)
      setPreviewUrls(newPreviewUrls)
      setImageLoadError({})
    }
  }

  const removeFile = (index: number) => {
    // Clean up the preview URL
    URL.revokeObjectURL(previewUrls[index])

    // Remove the file and preview URL from state
    setSelectedFiles((prev) => prev.filter((_, i) => i !== index))
    setPreviewUrls((prev) => prev.filter((_, i) => i !== index))

    // Update error state
    const newErrorState = { ...imageLoadError }
    delete newErrorState[previewUrls[index]]
    setImageLoadError(newErrorState)
  }

  const openImageViewer = (index: number) => {
    setCurrentImageIndex(index)
    setIsImageViewerOpen(true)
  }

  const handleNextImage = () => {
    setCurrentImageIndex((prev) => (prev + 1) % previewUrls.length)
  }

  const handlePreviousImage = () => {
    setCurrentImageIndex((prev) => (prev - 1 + previewUrls.length) % previewUrls.length)
  }

  const handleImageError = (url: string) => {
    console.error("Failed to load image preview:", url)
    setImageLoadError((prev) => ({ ...prev, [url]: true }))
  }

  const handleEmojiClick = (emojiData: EmojiClickData) => {
    const emoji = emojiData.emoji
    const cursorPosition = actualInputRef.current?.selectionStart || content.length
    const newContent = content.slice(0, cursorPosition) + emoji + content.slice(cursorPosition)
    setContent(newContent)
    
    // Focus back on input after emoji selection
    setTimeout(() => {
      if (actualInputRef.current) {
        actualInputRef.current.focus()
        actualInputRef.current.selectionStart = cursorPosition + emoji.length
        actualInputRef.current.selectionEnd = cursorPosition + emoji.length
      }
    }, 10)
  }

  const toggleEmojiPicker = () => {
    setShowEmojiPicker(prev => !prev)
  }

  return (
    <div className="flex-1">
      {/* Image previews */}
      {previewUrls.length > 0 && (
        <div className="mb-2 flex flex-wrap gap-2">
          {previewUrls.map((url, index) => (
            <div key={index} className="relative">
              <div
                className="relative w-20 h-20 rounded-lg overflow-hidden cursor-pointer bg-gray-100"
                onClick={() => openImageViewer(index)}
              >
                {imageLoadError[url] ? (
                  <div className="w-full h-full flex items-center justify-center bg-gray-200">
                    <ImageIcon className="h-8 w-8 text-gray-400" />
                  </div>
                ) : (
                  <img
                    src={url || "/placeholder.svg"}
                    alt={`Preview ${index + 1}`}
                    className="w-full h-full object-cover"
                    onError={() => handleImageError(url)}
                  />
                )}
              </div>
              <Button
                variant="ghost"
                size="icon"
                className="absolute -top-1 -right-1 h-5 w-5 rounded-full bg-gray-800 hover:bg-gray-900 text-white p-0"
                onClick={(e) => {
                  e.stopPropagation()
                  removeFile(index)
                }}
                disabled={isSubmitting}
              >
                <X className="h-3 w-3" />
              </Button>
            </div>
          ))}
        </div>
      )}

      {/* Input field with buttons */}
      <div className="flex items-center gap-2 bg-[#f0f2f5] rounded-full px-3 py-1">
        {/* Hidden file input */}
        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          multiple
          className="hidden"
          onChange={handleFileSelect}
          disabled={isSubmitting}
        />

        <input
          ref={actualInputRef}
          type="text"
          className="flex-1 bg-transparent border-none focus:outline-none text-[#0b0f19] placeholder-[#565973]"
          placeholder={isSubmitting ? "Sending comment..." : "Write a comment..."}
          value={content}
          onChange={(e) => setContent(e.target.value)}
          onFocus={() => onFocusChange(true)}
          onBlur={() => onFocusChange(false)}
          onKeyDown={handleKeyDown}
          disabled={isSubmitting}
        />
        <div className="flex items-center gap-1">
          <div className="relative">
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8 rounded-full text-[#565973] hover:bg-[#e4e6eb] emoji-toggle-button"
              onClick={toggleEmojiPicker}
              disabled={isSubmitting}
            >
              <Smile className="h-5 w-5" />
            </Button>
            
            {showEmojiPicker && (
              <div 
                className="absolute bottom-10 right-0 z-10" 
                ref={emojiPickerRef}
              >
                <EmojiPicker onEmojiClick={handleEmojiClick} />
              </div>
            )}
          </div>
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8 rounded-full text-[#565973] hover:bg-[#e4e6eb]"
            onClick={() => fileInputRef.current?.click()}
            disabled={isSubmitting}
          >
            <ImageIcon className="h-5 w-5" />
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className={`h-8 w-8 rounded-full ${
              isSubmitting
                ? "text-[#23c16b]"
                : content.trim() || selectedFiles.length > 0
                  ? "text-[#23c16b]"
                  : "text-[#9397ad]"
            }`}
            onClick={handleSubmit}
            disabled={(!content.trim() && selectedFiles.length === 0) || isSubmitting}
          >
            {isSubmitting ? <Loader2 className="h-5 w-5 animate-spin" /> : <Send className="h-5 w-5" />}
          </Button>
        </div>
      </div>

      {/* Image Viewer Modal */}
      {isImageViewerOpen && previewUrls.length > 0 && (
        <ImageViewer
          images={previewUrls}
          currentIndex={currentImageIndex}
          onClose={() => setIsImageViewerOpen(false)}
          onNext={handleNextImage}
          onPrevious={handlePreviousImage}
        />
      )}
    </div>
  )
}
