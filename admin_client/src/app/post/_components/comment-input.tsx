"use client"

import type React from "react"

import { useState, useEffect, useRef } from "react"
import { Button } from "@/components/ui/button"
import { Smile, Image, Send } from "lucide-react"

interface CommentInputProps {
  onAddComment: (content: string) => void
  isFocused: boolean
  onFocusChange: (isFocused: boolean) => void
  inputRef?: React.RefObject<HTMLInputElement | null>
}

export default function CommentInput({ onAddComment, isFocused, onFocusChange, inputRef }: CommentInputProps) {
  const [content, setContent] = useState("")
  const localInputRef = useRef<HTMLInputElement>(null)
  const actualInputRef = inputRef || localInputRef

  useEffect(() => {
    if (isFocused && actualInputRef.current) {
      actualInputRef.current.focus()
    }
  }, [isFocused, actualInputRef])

  const handleSubmit = () => {
    if (content.trim()) {
      onAddComment(content)
      setContent("")
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      handleSubmit()
    }
  }

  return (
    <div className="flex-1 flex items-center gap-2 bg-[#f0f2f5] rounded-full px-3 py-1">
      <input
        ref={actualInputRef}
        type="text"
        className="flex-1 bg-transparent border-none focus:outline-none text-[#0b0f19] placeholder-[#565973]"
        placeholder="Write a comment..."
        value={content}
        onChange={(e) => setContent(e.target.value)}
        onFocus={() => onFocusChange(true)}
        onBlur={() => onFocusChange(false)}
        onKeyDown={handleKeyDown}
      />
      <div className="flex items-center gap-1">
        <Button variant="ghost" size="icon" className="h-8 w-8 rounded-full text-[#565973] hover:bg-[#e4e6eb]">
          <Smile className="h-5 w-5" />
        </Button>
        <Button variant="ghost" size="icon" className="h-8 w-8 rounded-full text-[#565973] hover:bg-[#e4e6eb]">
          <Image className="h-5 w-5" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          className={`h-8 w-8 rounded-full ${content.trim() ? "text-[#23c16b]" : "text-[#9397ad]"}`}
          onClick={handleSubmit}
          disabled={!content.trim()}
        >
          <Send className="h-5 w-5" />
        </Button>
      </div>
    </div>
  )
}

