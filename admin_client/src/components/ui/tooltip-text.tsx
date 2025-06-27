"use client"

import { useState } from "react"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"

interface TooltipTextProps {
  text: string
  maxLength?: number
  className?: string
}

export function TooltipText({ text, maxLength = 50, className = "" }: TooltipTextProps) {
  const [isOpen, setIsOpen] = useState(false)
  
  if (!text || text.length <= maxLength) {
    return <span className={className}>{text}</span>
  }
  
  const truncatedText = text.substring(0, maxLength) + "..."
  
  return (
    <TooltipProvider>
      <Tooltip open={isOpen} onOpenChange={setIsOpen}>
        <TooltipTrigger asChild>
          <span 
            className={`cursor-help truncate ${className}`}
            onMouseEnter={() => setIsOpen(true)}
            onMouseLeave={() => setIsOpen(false)}
          >
            {truncatedText}
          </span>
        </TooltipTrigger>
        <TooltipContent className="max-w-xs">
          <p className="text-sm">{text}</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  )
}
