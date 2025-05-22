"use client"

import type React from "react"
import { useState, useRef } from "react"
import { Paperclip, ImageIcon, Mic, Smile, Send, X } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { TooltipProvider, Tooltip, TooltipTrigger, TooltipContent } from "@/components/ui/tooltip"
import Image from "next/image"

interface MessageInputProps {
  message: string
  setMessage: (message: string) => void
  onSendMessage: (message: string, imageUrl?: string) => void
  onKeyPress: (e: React.KeyboardEvent) => void
}

export default function MessageInput({ message, setMessage, onSendMessage, onKeyPress }: MessageInputProps) {
  const [selectedImage, setSelectedImage] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file && file.type.startsWith("image/")) {
      const reader = new FileReader()
      reader.onload = (event) => {
        if (event.target?.result) {
          setSelectedImage(event.target.result as string)
        }
      }
      reader.readAsDataURL(file)
    }
  }

  const handleSendClick = () => {
    // Don't send if both message and image are empty
    if (message.trim() === "" && !selectedImage) return

    // Send the message with image if available
    onSendMessage(message, selectedImage || undefined)

    // Reset state
    setMessage("")
    setSelectedImage(null)

    // Clear the file input
    if (fileInputRef.current) {
      fileInputRef.current.value = ""
    }
  }

  const handleKeyPressWithImage = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      handleSendClick()
    } else {
      onKeyPress(e)
    }
  }

  const removeSelectedImage = () => {
    setSelectedImage(null)
    if (fileInputRef.current) {
      fileInputRef.current.value = ""
    }
  }

  const triggerImageUpload = () => {
    fileInputRef.current?.click()
  }

  return (
    <div className="p-4 border-t border-[#e5e7eb] bg-white w-full">
      {selectedImage && (
        <div className="max-w-4xl mx-auto mb-3 relative">
          <div className="relative rounded-lg overflow-hidden border border-[#e5e7eb] inline-block max-w-xs">
            <Image
              src={selectedImage || "/placeholder.svg"}
              alt="Selected image"
              width={200}
              height={150}
              className="object-contain max-h-[150px]"
            />
            <button
              onClick={removeSelectedImage}
              className="absolute top-1 right-1 bg-black bg-opacity-50 rounded-full p-1 text-white hover:bg-opacity-70 transition-colors"
            >
              <X className="w-4 h-4" />
            </button>
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
                >
                  <Paperclip className="w-5 h-5" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Attach file</p>
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
                >
                  <ImageIcon className="w-5 h-5" />
                </Button>
              </TooltipTrigger>
              <TooltipContent>
                <p>Send image</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>

          <input type="file" ref={fileInputRef} className="hidden" accept="image/*" onChange={handleImageSelect} />
        </div>

        <div className="flex-1 relative">
          <Input
            type="text"
            placeholder="Type a message..."
            className="w-full py-3 px-4 bg-[#f8f9fd] border border-[#e5e7eb] rounded-full pr-24 focus-visible:ring-[#23c16b]"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={handleKeyPressWithImage}
          />
          <div className="absolute right-3 top-1/2 transform -translate-y-1/2 flex items-center gap-3">
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8 rounded-full text-[#64748b] hover:bg-[#f1f5f9] hover:text-[#334155]"
            >
              <Smile className="w-5 h-5" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8 rounded-full text-[#64748b] hover:bg-[#f1f5f9] hover:text-[#334155]"
            >
              <Mic className="w-5 h-5" />
            </Button>
          </div>
        </div>

        <Button
          className="bg-[#23c16b] hover:bg-[#1ea55a] h-10 w-10 rounded-full flex items-center justify-center text-white shadow-sm"
          onClick={handleSendClick}
          disabled={message.trim() === "" && !selectedImage}
        >
          <Send className="w-5 h-5" />
        </Button>
      </div>
    </div>
  )
}
