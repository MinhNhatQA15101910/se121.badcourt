"use client"

import type React from "react"

import { MapPin, Calendar, X, ExternalLink, CheckCircle, XCircle, Clock } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog"
import { VisuallyHidden } from "@radix-ui/react-visually-hidden"
import { Separator } from "@/components/ui/separator"
import { Badge } from "@/components/ui/badge"
import { useState } from "react"
import Image from "next/image"

// Sample data for demonstration
const sampleImages = [
  "/placeholder.svg?height=100&width=100",
  "/placeholder.svg?height=100&width=100",
  "/placeholder.svg?height=100&width=100",
  "/placeholder.svg?height=100&width=100",
]

const moreImages = [
  "/placeholder.svg?height=100&width=100",
  "/placeholder.svg?height=100&width=100",
  "/placeholder.svg?height=100&width=100",
  "/placeholder.svg?height=100&width=100",
  "/placeholder.svg?height=100&width=100",
  "/placeholder.svg?height=100&width=100",
]

type FacilityStatus = "Unactivated" | "Activated" | "Rejected"

interface FacilityDetailsProps {
  facilityId: string
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function FacilityDetails({ facilityId, open, onOpenChange }: FacilityDetailsProps) {
  const [status, setStatus] = useState<FacilityStatus>("Unactivated")

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md sm:max-w-xl md:max-w-2xl p-0 rounded-lg border shadow-lg max-h-[90vh] flex flex-col">
        <VisuallyHidden>
          <DialogTitle>Facility Details</DialogTitle>
        </VisuallyHidden>

        {/* Header with title and close button - fixed */}
        <div className="flex items-center justify-between p-4 border-b bg-white z-10  rounded-t-lg">
          <div className="flex items-center gap-2">
            <h1 className="text-lg font-semibold text-[#27272a]">Sân cầu lông nhật duy</h1>
            <StatusBadge status={status} />
          </div>
          <Button variant="ghost" size="icon" className="h-8 w-8 rounded-full" onClick={() => onOpenChange(false)}>
            <X className="w-4 h-4" />
          </Button>
        </div>

        {/* Scrollable content area using native scrolling */}
        <div className="flex-1 overflow-y-auto">
          {/* Court image */}
          <div className="relative w-full h-64 bg-[#f2f2f2] flex items-center justify-center">
            <div className="w-16 h-16 flex items-center justify-center rounded-full bg-white/80">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path
                  d="M4 16L8.586 11.414C8.96106 11.0391 9.46967 10.8284 10 10.8284C10.5303 10.8284 11.0389 11.0391 11.414 11.414L16 16M14 14L15.586 12.414C15.9611 12.0391 16.4697 11.8284 17 11.8284C17.5303 11.8284 18.0389 12.0391 18.414 12.414L20 14M14 8H14.01M6 20H18C18.5304 20 19.0391 19.7893 19.4142 19.4142C19.7893 19.0391 20 18.5304 20 18V6C20 5.46957 19.7893 4.96086 19.4142 4.58579C19.0391 4.21071 18.5304 4 18 4H6C5.46957 4 4.96086 4.21071 4.58579 4.58579C4.21071 4.96086 4 5.46957 4 6V18C4 18.5304 4.21071 19.0391 4.58579 19.4142C4.96086 19.7893 5.46957 20 6 20Z"
                  stroke="#9CA3AF"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </div>
            <div className="absolute bottom-0 left-0 right-0 bg-[#4b4b4b] text-white p-3 text-sm">ID: {facilityId}</div>
          </div>

          {/* Location and date info */}
          <div className="p-4 space-y-3">
            <div className="flex items-start gap-2">
              <MapPin className="w-5 h-5 shrink-0 text-[#198155] mt-0.5" />
              <span className="text-[#4b4b4b]">288 Erie Street South Unit D, Leamington, Ontario</span>
            </div>
            <div className="flex items-center gap-2">
              <Calendar className="w-5 h-5 shrink-0 text-[#198155]" />
              <span className="text-[#4b4b4b]">Monday, 26/03/2023</span>
            </div>
          </div>

          <Separator />

          {/* User profile section */}
          <div className="p-4 flex items-center gap-4">
            <div className="w-16 h-16 rounded-full bg-[#f0f0f0] flex items-center justify-center">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path
                  d="M20 21V19C20 17.9391 19.5786 16.9217 18.8284 16.1716C18.0783 15.4214 17.0609 15 16 15H8C6.93913 15 5.92172 15.4214 5.17157 16.1716C4.42143 16.9217 4 17.9391 4 19V21M16 7C16 9.20914 14.2091 11 12 11C9.79086 11 8 9.20914 8 7C8 4.79086 9.79086 3 12 3C14.2091 3 16 4.79086 16 7Z"
                  stroke="#9CA3AF"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </div>
            <div>
              <h2 className="font-medium text-base">Mai Hoàng Nhật Duy</h2>
              <p className="text-[#808089] text-sm">ID: 000000000</p>
            </div>
          </div>

          <Separator />

          {/* Document sections */}
          <div className="p-4 space-y-6">
            <DocumentSection
              title="Photos of citizen identification card"
              images={sampleImages.slice(0, 2)}
              sectionId="id-card"
            />

            <DocumentSection title="Photos of bank card" images={sampleImages.slice(0, 2)} sectionId="bank-card" />

            <DocumentSection title="Photos of business license" images={moreImages} sectionId="business-license" />

            <DocumentSection title="Photos of tax code" images={sampleImages.slice(0, 2)} sectionId="tax-code" />

            <DocumentSection
              title="Photos of relevant documents"
              images={moreImages.slice(0, 5)}
              sectionId="relevant-docs"
            />
          </div>
        </div>

        {/* Footer buttons - fixed */}
        <div className="flex gap-3 p-4 border-t bg-white z-10 rounded-b-lg">
          <Button
            variant="outline"
            className="flex-1 border-[#23c16b] text-[#23c16b] hover:bg-[#23c16b]/10 hover:text-[#23c16b]"
          >
            Chat with owner
          </Button>
          <Button
            className="flex-1 bg-[#23c16b] hover:bg-[#23c16b]/90 text-white"
            onClick={() => setStatus("Activated")}
          >
            Activate
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}

function StatusBadge({ status }: { status: FacilityStatus }) {
  switch (status) {
    case "Activated":
      return (
        <Badge className="bg-green-100 text-green-800 hover:bg-green-100 flex items-center gap-1">
          <CheckCircle className="w-3 h-3" /> Activated
        </Badge>
      )
    case "Rejected":
      return (
        <Badge className="bg-red-100 text-red-800 hover:bg-red-100 flex items-center gap-1">
          <XCircle className="w-3 h-3" /> Rejected
        </Badge>
      )
    default:
      return (
        <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-100 flex items-center gap-1">
          <Clock className="w-3 h-3" /> Unactivated
        </Badge>
      )
  }
}

function DocumentSection({
  title,
  images,
}: {
  title: string
  images: string[]
  sectionId: string
}) {
  const handleImageClick = (imageUrl: string, index: number, e: React.MouseEvent) => {
    e.preventDefault()

    // Open a new window with the image
    const newWindow = window.open("", "_blank")
    if (!newWindow) return

    // Create a JSON string of all images in this section
    const imagesJson = JSON.stringify(images)

    // Create HTML content for the new window with image viewer functionality
    const html = `
      <!DOCTYPE html>
      <html>
        <head>
          <title>Image Viewer - ${title}</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              margin: 0;
              padding: 0;
              display: flex;
              flex-direction: column;
              height: 100vh;
              background-color: #1a1a1a;
              color: white;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            }
            .toolbar {
              display: flex;
              justify-content: space-between;
              padding: 12px;
              background-color: #2a2a2a;
            }
            .toolbar-left {
              display: flex;
              align-items: center;
            }
            .toolbar-right {
              display: flex;
              gap: 8px;
            }
            .toolbar button {
              background-color: #444;
              border: none;
              color: white;
              padding: 8px 12px;
              border-radius: 4px;
              cursor: pointer;
              display: flex;
              align-items: center;
              gap: 4px;
            }
            .toolbar button:hover {
              background-color: #555;
            }
            .toolbar button:disabled {
              opacity: 0.5;
              cursor: not-allowed;
            }
            .image-container {
              flex: 1;
              display: flex;
              align-items: center;
              justify-content: center;
              overflow: hidden;
              position: relative;
            }
            img {
              max-width: 100%;
              max-height: 100%;
              object-fit: contain;
              transition: transform 0.3s ease;
            }
            .icon {
              width: 16px;
              height: 16px;
            }
            .navigation-buttons {
              position: absolute;
              top: 0;
              left: 0;
              right: 0;
              bottom: 0;
              display: flex;
              justify-content: space-between;
              align-items: center;
              padding: 0 20px;
              pointer-events: none;
            }
            .nav-button {
              background-color: rgba(0, 0, 0, 0.5);
              border: none;
              color: white;
              width: 40px;
              height: 40px;
              border-radius: 50%;
              display: flex;
              align-items: center;
              justify-content: center;
              cursor: pointer;
              pointer-events: auto;
            }
            .nav-button:hover {
              background-color: rgba(0, 0, 0, 0.7);
            }
            .nav-button:disabled {
              opacity: 0.3;
              cursor: not-allowed;
            }
            .image-counter {
              color: #ccc;
              margin-left: 10px;
            }
          </style>
        </head>
        <body>
          <div class="toolbar">
            <div class="toolbar-left">
              <span class="image-counter">Image <span id="current-index">1</span> of <span id="total-images">1</span></span>
            </div>
            <div class="toolbar-right">
              <button id="zoom-in">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="11" cy="11" r="8"></circle>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                  <line x1="11" y1="8" x2="11" y2="14"></line>
                  <line x1="8" y1="11" x2="14" y2="11"></line>
                </svg>
                Zoom In
              </button>
              <button id="zoom-out">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="11" cy="11" r="8"></circle>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                  <line x1="8" y1="11" x2="14" y2="11"></line>
                </svg>
                Zoom Out
              </button>
              <button id="download">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                  <polyline points="7 10 12 15 17 10"></polyline>
                  <line x1="12" y1="15" x2="12" y2="3"></line>
                </svg>
                Download
              </button>
            </div>
          </div>
          <div class="image-container">
            <img id="image" src="${imageUrl}" alt="Document Image">
            <div class="navigation-buttons">
              <button id="prev-button" class="nav-button">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="15 18 9 12 15 6"></polyline>
                </svg>
              </button>
              <button id="next-button" class="nav-button">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="9 18 15 12 9 6"></polyline>
                </svg>
              </button>
            </div>
          </div>
          
          <script>
            // Parse the images array from JSON
            const images = ${imagesJson};
            let currentIndex = ${index};
            let scale = 1;
            
            const image = document.getElementById('image');
            const zoomIn = document.getElementById('zoom-in');
            const zoomOut = document.getElementById('zoom-out');
            const download = document.getElementById('download');
            const prevButton = document.getElementById('prev-button');
            const nextButton = document.getElementById('next-button');
            const currentIndexEl = document.getElementById('current-index');
            const totalImagesEl = document.getElementById('total-images');
            
            // Update the image counter
            totalImagesEl.textContent = images.length;
            updateImageCounter();
            updateNavigationButtons();
            
            // Zoom functionality
            zoomIn.addEventListener('click', () => {
              scale += 0.2;
              image.style.transform = \`scale(\${scale})\`;
            });
            
            zoomOut.addEventListener('click', () => {
              if (scale > 0.4) {
                scale -= 0.2;
                image.style.transform = \`scale(\${scale})\`;
              }
            });
            
            // Download functionality
            download.addEventListener('click', () => {
              const a = document.createElement('a');
              a.href = image.src;
              a.download = 'document-image-' + (currentIndex + 1) + '.jpg';
              document.body.appendChild(a);
              a.click();
              document.body.removeChild(a);
            });
            
            // Navigation functionality
            prevButton.addEventListener('click', () => {
              if (currentIndex > 0) {
                currentIndex--;
                updateImage();
                updateImageCounter();
                updateNavigationButtons();
                // Reset zoom when changing images
                scale = 1;
                image.style.transform = '';
              }
            });
            
            nextButton.addEventListener('click', () => {
              if (currentIndex < images.length - 1) {
                currentIndex++;
                updateImage();
                updateImageCounter();
                updateNavigationButtons();
                // Reset zoom when changing images
                scale = 1;
                image.style.transform = '';
              }
            });
            
            // Keyboard navigation
            document.addEventListener('keydown', (e) => {
              if (e.key === 'ArrowLeft' && currentIndex > 0) {
                prevButton.click();
              } else if (e.key === 'ArrowRight' && currentIndex < images.length - 1) {
                nextButton.click();
              }
            });
            
            function updateImage() {
              image.src = images[currentIndex];
            }
            
            function updateImageCounter() {
              currentIndexEl.textContent = currentIndex + 1;
            }
            
            function updateNavigationButtons() {
              prevButton.disabled = currentIndex === 0;
              nextButton.disabled = currentIndex === images.length - 1;
            }
          </script>
        </body>
      </html>
    `

    // Write the HTML content to the new window
    newWindow.document.write(html)
    newWindow.document.close()
  }

  return (
    <div>
      <h3 className="font-medium text-sm mb-3">{title}</h3>
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
        {images.map((image, index) => (
          <div
            key={index}
            className="relative group aspect-square bg-[#f2f4f5] rounded-md overflow-hidden border flex items-center justify-center cursor-pointer"
            onClick={(e) => handleImageClick(image, index, e)}
          >
            <Image
              src={image || "/placeholder.svg"}
              alt={`${title} - Image ${index + 1}`}
              width={500}
              height={500}
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100">
              <ExternalLink className="w-4 h-4 text-white" />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

