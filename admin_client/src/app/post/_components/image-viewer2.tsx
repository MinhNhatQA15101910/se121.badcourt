"use client"

import { useEffect, useState } from "react"
import { X, ChevronLeft, ChevronRight, ImageIcon } from 'lucide-react'
import { Button } from "@/components/ui/button"

interface ImageViewerProps {
  images: string[]
  currentIndex: number
  onClose: () => void
  onNext: () => void
  onPrevious: () => void
}

export default function ImageViewer({ images, currentIndex, onClose, onNext, onPrevious }: ImageViewerProps) {
  const [isLoading, setIsLoading] = useState(true)
  const [loadError, setLoadError] = useState(false)

  // Prevent body scrolling when modal is open
  useEffect(() => {
    document.body.style.overflow = "hidden"
    return () => {
      document.body.style.overflow = "auto"
    }
  }, [])

  // Handle image loading
  useEffect(() => {
    if (!images || images.length === 0) return

    setIsLoading(true)
    setLoadError(false)
    
    const img = document.createElement("img")
    img.src = images[currentIndex]
    img.onload = () => setIsLoading(false)
    img.onerror = () => {
      console.error("Failed to load image:", images[currentIndex])
      setIsLoading(false)
      setLoadError(true)
    }
  }, [currentIndex, images])

  // Safety check
  if (!images || images.length === 0 || currentIndex >= images.length) {
    return null
  }

  return (
    <div className="fixed inset-0 z-[9999] bg-black/90 flex items-center justify-center" onClick={onClose}>
      <div className="absolute top-4 right-4 z-10">
        <Button
          variant="ghost"
          size="icon"
          className="h-10 w-10 rounded-full bg-black/50 text-white hover:bg-black/70"
          onClick={(e) => {
            e.stopPropagation()
            onClose()
          }}
        >
          <X className="h-6 w-6" />
        </Button>
      </div>

      <div
        className="relative max-w-[90vw] max-h-[90vh] flex items-center justify-center"
        onClick={(e) => e.stopPropagation()}
      >
        {isLoading && (
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="h-8 w-8 border-4 border-t-[#23c16b] border-r-transparent border-b-transparent border-l-transparent rounded-full animate-spin"></div>
          </div>
        )}

        <div className="relative w-full h-[90vh] flex items-center justify-center">
          {loadError ? (
            <div className="flex flex-col items-center justify-center text-white">
              <ImageIcon className="h-16 w-16 mb-4" />
              <p>Failed to load image</p>
            </div>
          ) : (
            <img
              src={images[currentIndex] || "/placeholder.svg"}
              alt="Full size image"
              className={`max-h-[90vh] max-w-[90vw] object-contain transition-opacity duration-300 ${
                isLoading ? "opacity-0" : "opacity-100"
              }`}
              onError={() => setLoadError(true)}
            />
          )}
        </div>

        {images.length > 1 && (
          <>
            <Button
              variant="ghost"
              size="icon"
              className="absolute left-4 top-1/2 transform -translate-y-1/2 h-12 w-12 rounded-full bg-black/50 text-white hover:bg-black/70"
              onClick={(e) => {
                e.stopPropagation()
                onPrevious()
              }}
            >
              <ChevronLeft className="h-8 w-8" />
            </Button>

            <Button
              variant="ghost"
              size="icon"
              className="absolute right-4 top-1/2 transform -translate-y-1/2 h-12 w-12 rounded-full bg-black/50 text-white hover:bg-black/70"
              onClick={(e) => {
                e.stopPropagation()
                onNext()
              }}
            >
              <ChevronRight className="h-8 w-8" />
            </Button>

            <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex gap-2">
              {images.map((_, index) => (
                <div
                  key={index}
                  className={`h-2 w-2 rounded-full ${index === currentIndex ? "bg-white" : "bg-white/50"}`}
                />
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  )
}
