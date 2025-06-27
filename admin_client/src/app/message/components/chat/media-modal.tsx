"use client"

import type React from "react"

import { useState } from "react"
import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { X, Download, ZoomIn, ZoomOut } from "lucide-react"
import Image from "next/image"

interface MediaModalProps {
  src: string
  alt: string
  fileType: string
  fileName?: string
  children: React.ReactNode
}

export default function MediaModal({ src, alt, fileType, fileName, children }: MediaModalProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [zoom, setZoom] = useState(1)

  const isImage = fileType.toLowerCase().includes("image")
  const isVideo = fileType.toLowerCase().includes("video")

  const handleDownload = () => {
    const link = document.createElement("a")
    link.href = src
    link.download = fileName || "media"
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  const handleZoomIn = () => {
    setZoom((prev) => Math.min(prev + 0.25, 3))
  }

  const handleZoomOut = () => {
    setZoom((prev) => Math.max(prev - 0.25, 0.5))
  }

  const resetZoom = () => {
    setZoom(1)
  }

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger asChild>{children}</DialogTrigger>
      <DialogContent className="max-w-4xl max-h-[90vh] p-0 overflow-hidden">
        <div className="relative bg-black">
          {/* Header */}
          <div className="absolute top-0 left-0 right-0 z-10 flex items-center justify-between p-4 bg-black/50 backdrop-blur-sm">
            <div className="text-white text-sm truncate">{fileName || alt}</div>
            <div className="flex items-center gap-2">
              {isImage && (
                <>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="text-white hover:bg-white/20"
                    onClick={handleZoomOut}
                    disabled={zoom <= 0.5}
                  >
                    <ZoomOut className="w-4 h-4" />
                  </Button>
                  <Button variant="ghost" size="icon" className="text-white hover:bg-white/20" onClick={resetZoom}>
                    <span className="text-xs">{Math.round(zoom * 100)}%</span>
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="text-white hover:bg-white/20"
                    onClick={handleZoomIn}
                    disabled={zoom >= 3}
                  >
                    <ZoomIn className="w-4 h-4" />
                  </Button>
                </>
              )}
              <Button variant="ghost" size="icon" className="text-white hover:bg-white/20" onClick={handleDownload}>
                <Download className="w-4 h-4" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                className="text-white hover:bg-white/20"
                onClick={() => setIsOpen(false)}
              >
                <X className="w-4 h-4" />
              </Button>
            </div>
          </div>

          {/* Media Content */}
          <div className="flex items-center justify-center min-h-[400px] max-h-[80vh] overflow-auto">
            {isImage ? (
              <div className="transition-transform duration-200" style={{ transform: `scale(${zoom})` }}>
                <Image
                  src={src || "/placeholder.svg"}
                  alt={alt}
                  width={800}
                  height={600}
                  className="max-w-full max-h-full object-contain"
                  unoptimized
                />
              </div>
            ) : isVideo ? (
              <video src={src} controls className="max-w-full max-h-full" style={{ maxHeight: "80vh" }}>
                Your browser does not support the video tag.
              </video>
            ) : (
              <div className="text-white p-8 text-center">
                <p>Preview not available for this file type</p>
                <Button variant="outline" className="mt-4" onClick={handleDownload}>
                  <Download className="w-4 h-4 mr-2" />
                  Download File
                </Button>
              </div>
            )}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
