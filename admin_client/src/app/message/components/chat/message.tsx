"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { CheckCheck, FileIcon, Download, Play } from "lucide-react"
import Image from "next/image"
import type { MessageType } from "@/lib/types"
import { useState, useEffect } from "react"
import MediaModal from "./media-modal"
import { Button } from "@/components/ui/button"

interface MessageResource {
  id: string
  url: string
  fileName?: string
  fileType?: string
  fileSize?: number
}

interface MessageProps {
  message: MessageType
  conversationName: string
  conversationAvatar: string
  onMessageRead?: (messageId: string) => void
}

export default function Message({ message, conversationName, conversationAvatar, onMessageRead }: MessageProps) {
  const [imageError, setImageError] = useState(false)

  // Intersection Observer to detect when message is visible
  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !message.sent && onMessageRead) {
          onMessageRead(message.id.toString())
        }
      },
      { threshold: 0.5 },
    )

    const messageElement = document.getElementById(`message-${message.id}`)
    if (messageElement) {
      observer.observe(messageElement)
    }

    return () => {
      if (messageElement) {
        observer.unobserve(messageElement)
      }
    }
  }, [message.id, message.sent, onMessageRead])

  // Helper function to get file type from URL or resource
  const getFileType = (url: string, resource?: MessageResource) => {
    if (resource?.fileType) {
      return resource.fileType.toLowerCase()
    }
    const extension = url.split(".").pop()?.toLowerCase()
    if (["jpg", "jpeg", "png", "gif", "webp", "svg"].includes(extension || "")) {
      return "image"
    }
    if (["mp4", "webm", "ogg", "avi", "mov"].includes(extension || "")) {
      return "video"
    }
    return "file"
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
    <div id={`message-${message.id}`} className={`flex ${message.sent ? "justify-end" : "justify-start"}`}>
      <div className={`flex gap-2 max-w-[80%] ${message.sent ? "flex-row-reverse" : ""}`}>
        {!message.sent && (
          <Avatar className="w-8 h-8 mt-1">
            <AvatarImage
              src={message.senderImageUrl || conversationAvatar || "/placeholder.svg"}
              alt={message.senderUsername || conversationName}
            />
            <AvatarFallback>{(message.senderUsername || conversationName).charAt(0)}</AvatarFallback>
          </Avatar>
        )}
        <div className="flex flex-col gap-1">
          <div
            className={`${
              message.sent
                ? "bg-green-500 text-white rounded-2xl rounded-tr-sm shadow-sm"
                : "bg-white border border-gray-200 rounded-2xl rounded-tl-sm shadow-sm"
            } 
              p-3 px-4`}
          >
            {/* Show sender name for group messages */}
            {!message.sent && message.senderUsername && (
              <div className="text-xs font-medium text-gray-600 mb-1">{message.senderUsername}</div>
            )}

            {/* Message text */}
            {message.text && message.text.trim() !== "" && <p className="text-sm">{message.text}</p>}

            {/* Display legacy image if available */}
            {message.imageUrl && !imageError && (
              <div className={`${message.text && message.text.trim() !== "" ? "mt-2" : ""} rounded-lg overflow-hidden`}>
                <MediaModal src={message.imageUrl} alt="Shared image" fileType="image" fileName="image">
                  <div className="cursor-pointer hover:opacity-90 transition-opacity">
                    <Image
                      src={message.imageUrl || "/placeholder.svg"}
                      alt="Shared image"
                      width={300}
                      height={200}
                      className="rounded-lg max-w-full object-contain"
                      onError={() => setImageError(true)}
                    />
                  </div>
                </MediaModal>
              </div>
            )}

            {/* Display resources/files */}
            {message.resources && message.resources.length > 0 && (
              <div className={`${message.text && message.text.trim() !== "" ? "mt-2" : ""} space-y-2`}>
                {message.resources.map((resource) => {
                  const fileType = getFileType(resource.url, resource)
                  const isImage = fileType.includes("image")
                  const isVideo = fileType.includes("video")

                  if (isImage) {
                    return (
                      <div key={resource.id} className="rounded-lg overflow-hidden">
                        <MediaModal
                          src={resource.url}
                          alt={resource.fileName || "Image"}
                          fileType={resource.fileType || "image"}
                          fileName={resource.fileName}
                        >
                          <div className="cursor-pointer hover:opacity-90 transition-opacity relative group">
                            <Image
                              src={resource.url || "/placeholder.svg"}
                              alt={resource.fileName || "Image"}
                              width={300}
                              height={200}
                              className="rounded-lg max-w-full object-contain"
                              unoptimized
                            />
                            <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors rounded-lg flex items-center justify-center">
                              <div className="opacity-0 group-hover:opacity-100 transition-opacity bg-black/50 rounded-full p-2">
                                <svg
                                  className="w-6 h-6 text-white"
                                  fill="none"
                                  stroke="currentColor"
                                  viewBox="0 0 24 24"
                                >
                                  <path
                                    strokeLinecap="round"
                                    strokeLinejoin="round"
                                    strokeWidth={2}
                                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7"
                                  />
                                </svg>
                              </div>
                            </div>
                          </div>
                        </MediaModal>
                      </div>
                    )
                  }

                  if (isVideo) {
                    return (
                      <div key={resource.id} className="rounded-lg overflow-hidden">
                        <MediaModal
                          src={resource.url}
                          alt={resource.fileName || "Video"}
                          fileType={resource.fileType || "video"}
                          fileName={resource.fileName}
                        >
                          <div className="cursor-pointer hover:opacity-90 transition-opacity relative group">
                            <div className="relative w-[300px] h-[200px] bg-black rounded-lg overflow-hidden">
                              <video
                                src={resource.url}
                                className="w-full h-full object-contain"
                                poster="/placeholder.svg?height=200&width=300"
                                preload="metadata"
                                onLoadedMetadata={(e) => {
                                  // Seek to 1 second to get a better thumbnail
                                  const video = e.target as HTMLVideoElement
                                  if (video.duration > 2) {
                                    video.currentTime = 1
                                  }
                                }}
                              />
                              <div className="absolute inset-0 bg-black/20 group-hover:bg-black/30 transition-colors rounded-lg flex items-center justify-center">
                                <div className="bg-black/50 rounded-full p-3">
                                  <Play className="w-8 h-8 text-white fill-white" />
                                </div>
                              </div>
                            </div>
                          </div>
                        </MediaModal>
                        <div className="mt-1 text-xs text-gray-500">
                          {resource.fileName} {resource.fileSize && `(${formatFileSize(resource.fileSize)})`}
                        </div>
                      </div>
                    )
                  }

                  // Regular file
                  return (
                    <div key={resource.id} className="flex items-center gap-2 p-2 bg-gray-50 rounded-lg">
                      <FileIcon className="w-4 h-4 text-gray-500 flex-shrink-0" />
                      <div className="flex-1 min-w-0">
                        <div className="text-xs font-medium truncate">{resource.fileName}</div>
                        {resource.fileSize && (
                          <div className="text-xs text-gray-500">{formatFileSize(resource.fileSize)}</div>
                        )}
                      </div>
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6 flex-shrink-0"
                        onClick={() => {
                          const link = document.createElement("a")
                          link.href = resource.url
                          link.download = resource.fileName || "file"
                          document.body.appendChild(link)
                          link.click()
                          document.body.removeChild(link)
                        }}
                      >
                        <Download className="w-3 h-3" />
                      </Button>
                    </div>
                  )
                })}
              </div>
            )}

            {/* Legacy support for hasImage property */}
            {(message.hasImage || imageError) && !message.resources?.length && (
              <div className={`${message.text && message.text.trim() !== "" ? "mt-2" : ""} rounded-lg overflow-hidden`}>
                <Image
                  src="/placeholder.svg?height=200&width=300"
                  alt="Image placeholder"
                  width={300}
                  height={200}
                  className="rounded-lg"
                />
              </div>
            )}
          </div>
          <div className={`flex items-center gap-1 ${message.sent ? "justify-end" : ""}`}>
            <span className="text-xs text-slate-400">{message.time}</span>
            {message.sent && <CheckCheck className="w-3 h-3 text-green-500" />}
          </div>
        </div>
      </div>
    </div>
  )
}
