"use client"

import type React from "react"
import { useState, useRef } from "react"
import { Video, ImageIcon, Mic, Smile, Send, X, Paperclip } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { TooltipProvider, Tooltip, TooltipTrigger, TooltipContent } from "@/components/ui/tooltip"
import Image from "next/image"

interface MessageInputProps {
  message: string
  setMessage: (message: string) => void
  onSendMessage: (message: string, files?: File[]) => void
  onKeyPress: (e: React.KeyboardEvent) => void
  disabled?: boolean
}

export default function MessageInput({ message, setMessage, onSendMessage, onKeyPress, disabled }: MessageInputProps) {
  const [selectedFiles, setSelectedFiles] = useState<File[]>([])
  const fileInputRef = useRef<HTMLInputElement>(null)
  const imageInputRef = useRef<HTMLInputElement>(null)

  const handleVideoSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    const videoFiles = files.filter((file) => file.type.startsWith("video/"))
    if (videoFiles.length > 0) {
      setSelectedFiles((prev) => [...prev, ...videoFiles])
    }
  }

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    const imageFiles = files.filter((file) => file.type.startsWith("image/"))
    if (imageFiles.length > 0) {
      setSelectedFiles((prev) => [...prev, ...imageFiles])
    }
  }

  const handleSendClick = () => {
    // Don't send if both message and files are empty
    if (message.trim() === "" && selectedFiles.length === 0) return

    // Send the message with files
    onSendMessage(message, selectedFiles)

    // Reset state
    setMessage("")
    setSelectedFiles([])

    // Clear the file inputs
    if (fileInputRef.current) {
      fileInputRef.current.value = ""
    }
    if (imageInputRef.current) {
      imageInputRef.current.value = ""
    }
  }

  const handleKeyPressWithFiles = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey && !disabled) {
      e.preventDefault()
      handleSendClick()
    } else {
      onKeyPress(e)
    }
  }

  const removeSelectedFile = (index: number) => {
    setSelectedFiles((prev) => prev.filter((_, i) => i !== index))
  }

  const triggerVideoUpload = () => {
    fileInputRef.current?.click()
  }

  const triggerImageUpload = () => {
    imageInputRef.current?.click()
  }

  // Helper function to get file preview
  const getFilePreview = (file: File) => {
    if (file.type.startsWith("image/")) {
      return URL.createObjectURL(file)
    }
    return null
  }

  // Helper function to format file size
  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return "0 Bytes"
    const k = 1024
    const sizes = ["Bytes", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return Number.parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i]
  }

  return (
    <div className="p-4 border-t border-[#e5e7eb] bg-white w-full">
      {/* Selected Files Preview */}
      {selectedFiles.length > 0 && (
        <div className="max-w-4xl mx-auto mb-3">
          <div className="flex flex-wrap gap-2">
            {selectedFiles.map((file, index) => {
              const preview = getFilePreview(file)
              return (
                <div key={index} className="relative border border-[#e5e7eb] rounded-lg p-2 bg-gray-50">
                  {preview ? (
                    <div className="relative">
                      <Image
                        src={preview || "/placeholder.svg"}
                        alt={file.name}
                        width={80}
                        height={80}
                        className="object-cover rounded"
                      />
                      <button
                        onClick={() => removeSelectedFile(index)}
                        className="absolute -top-1 -right-1 bg-red-500 rounded-full p-1 text-white hover:bg-red-600 transition-colors"
                      >
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  ) : (
                    <div className="flex items-center gap-2 min-w-[120px]">
                      <Paperclip className="w-4 h-4 text-gray-500" />
                      <div className="flex-1 min-w-0">
                        <div className="text-xs font-medium truncate">{file.name}</div>
                        <div className="text-xs text-gray-500">{formatFileSize(file.size)}</div>
                      </div>
                      <button
                        onClick={() => removeSelectedFile(index)}
                        className="text-red-500 hover:text-red-700 transition-colors"
                      >
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        </div>
      )}

      <div className="flex items-center gap-2 max-w-4xl mx-auto w-full">
        <div className="flex gap-2">
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  className="rounded-full text-[#64748b] hover:bg-[#f1f5f9] hover:text-[#334155]"
                  onClick={triggerVideoUpload}
                  disabled={disabled}
                >
                  <Video className="w-5 h-5" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Send video</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>

          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  className="rounded-full text-[#64748b] hover:bg-[#f1f5f9] hover:text-[#334155]"
                  onClick={triggerImageUpload}
                  disabled={disabled}
                >
                  <ImageIcon className="w-5 h-5" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Send image</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>

          <input
            type="file"
            ref={fileInputRef}
            className="hidden"
            accept="video/*"
            multiple
            onChange={handleVideoSelect}
            disabled={disabled}
          />
          <input
            type="file"
            ref={imageInputRef}
            className="hidden"
            accept="image/*"
            multiple
            onChange={handleImageSelect}
            disabled={disabled}
          />
        </div>

        <div className="flex-1 relative">
          <Input
            type="text"
            placeholder={disabled ? "Sending..." : "Type a message..."}
            className="w-full py-3 px-4 bg-[#f8f9fd] border border-[#e5e7eb] rounded-full pr-24 focus-visible:ring-[#23c16b]"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={handleKeyPressWithFiles}
            disabled={disabled}
          />
          <div className="absolute right-3 top-1/2 transform -translate-y-1/2 flex items-center gap-3">
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8 rounded-full text-[#64748b] hover:bg-[#f1f5f9] hover:text-[#334155]"
              disabled={disabled}
            >
              <Smile className="w-5 h-5" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8 rounded-full text-[#64748b] hover:bg-[#f1f5f9] hover:text-[#334155]"
              disabled={disabled}
            >
              <Mic className="w-5 h-5" />
            </Button>
          </div>
        </div>

        <Button
          className="bg-[#23c16b] hover:bg-[#1ea55a] h-10 w-10 rounded-full flex items-center justify-center text-white shadow-sm disabled:opacity-50"
          onClick={handleSendClick}
          disabled={disabled || (message.trim() === "" && selectedFiles.length === 0)}
        >
          <Send className="w-5 h-5" />
        </Button>
      </div>
    </div>
  )
}
