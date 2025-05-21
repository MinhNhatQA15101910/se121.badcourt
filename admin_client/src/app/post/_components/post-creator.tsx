"use client";

import type React from "react";

import { useState, useRef } from "react";
import { Button } from "@/components/ui/button";
import { UserAvatar } from "./user-avatar";
import { ImageIcon, MapPin, Smile, X, Tag } from "lucide-react";
import type { User } from "@/lib/types";
import Image from "next/image";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

interface PostCreatorProps {
  onCreatePost: (content: string, files: File[], category?: string) => void;
  currentUser: Partial<User>;
}

export default function PostCreator({
  onCreatePost,
  currentUser,
}: PostCreatorProps) {
  const [content, setContent] = useState("");
  const [isExpanded, setIsExpanded] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [files, setFiles] = useState<File[]>([]);
  const [previews, setPreviews] = useState<string[]>([]);
  const [activeTab, setActiveTab] = useState("post");
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFocus = () => {
    setIsExpanded(true);
  };

  const handleSubmit = () => {
    if (content.trim() || (activeTab === "photo" && files.length > 0)) {
      onCreatePost(content, files, selectedCategory || undefined);
      setContent("");
      setIsExpanded(false);
      setSelectedCategory(null);
      setFiles([]);
      setPreviews([]);
      setActiveTab("post");
    }
  };

  const handleFileSelect = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFiles = e.target.files;
    if (selectedFiles && selectedFiles.length > 0) {
      const newFiles = Array.from(selectedFiles);
      setFiles([...files, ...newFiles]);

      // Create previews for the files
      const newPreviews = Array.from(selectedFiles).map((file) =>
        URL.createObjectURL(file)
      );
      setPreviews([...previews, ...newPreviews]);
    }
  };

  const removeFile = (index: number) => {
    const newFiles = [...files];
    newFiles.splice(index, 1);
    setFiles(newFiles);

    const newPreviews = [...previews];
    URL.revokeObjectURL(newPreviews[index]); // Clean up the URL
    newPreviews.splice(index, 1);
    setPreviews(newPreviews);
  };

  const categories = [
    { id: "Sharing", name: "Sharing" },
    { id: "Question", name: "Question" },
    { id: "News", name: "News" },
    { id: "Event", name: "Event" },
  ];

  return (
    <div className="bg-white rounded-xl p-4 shadow-sm transition-all">
      <Tabs defaultValue="post" className="w-full" onValueChange={setActiveTab}>
        <TabsList className="grid grid-cols-2 mb-4">
          <TabsTrigger
            value="post"
            className="data-[state=active]:bg-[#23c16b] data-[state=active]:text-white"
          >
            Post
          </TabsTrigger>
          <TabsTrigger
            value="photo"
            className="data-[state=active]:bg-[#23c16b] data-[state=active]:text-white"
          >
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
              What on your mind,{" "}
              {currentUser.username?.split(" ")[0] || "there"}?
            </div>
            {isExpanded && (
              <div className="flex-1">
                <textarea
                  className="w-full bg-[#f0f2f5] rounded-lg px-4 py-3 text-[#0b0f19] placeholder-[#565973] focus:outline-none focus:ring-2 focus:ring-[#23c16b] resize-none min-h-[120px]"
                  placeholder={`What's on your mind, ${
                    currentUser.username?.split(" ")[0] || "there"
                  }?`}
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  autoFocus
                />
              </div>
            )}
          </div>

          {isExpanded && previews.length > 0 && (
            <div className="mt-4 grid grid-cols-2 md:grid-cols-3 gap-2">
              {previews.map((src, index) => (
                <div
                  key={index}
                  className="relative rounded-lg overflow-hidden aspect-video bg-[#f0f2f5]"
                >
                  <div className="relative h-full w-full">
                    <Image
                      src={src || "/placeholder.svg"}
                      alt="Media"
                      fill
                      className="object-cover"
                      sizes="100vw"
                    />
                  </div>
                  <button
                    className="absolute top-2 right-2 bg-black/50 rounded-full p-1 hover:bg-black/70 transition-colors"
                    onClick={() => removeFile(index)}
                  >
                    <X className="h-4 w-4 text-white" />
                  </button>
                </div>
              ))}
            </div>
          )}

          {isExpanded && (
            <div className="mt-4 p-3 bg-[#f0f2f5] rounded-lg flex items-center justify-between">
              <div className="text-sm font-medium text-[#0b0f19]">
                Add to your post
              </div>
              <div className="flex gap-2">
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-9 w-9 rounded-full hover:bg-[#e4e6eb]"
                  onClick={handleFileSelect}
                >
                  <ImageIcon className="h-5 w-5 text-[#f3425f]" />
                  <input
                    type="file"
                    ref={fileInputRef}
                    className="hidden"
                    accept="image/*"
                    multiple
                    onChange={handleFileChange}
                  />
                </Button>

                <Button
                  variant="ghost"
                  size="icon"
                  className="h-9 w-9 rounded-full hover:bg-[#e4e6eb]"
                >
                  <Smile className="h-5 w-5 text-[#f7b928]" />
                </Button>

                <Button
                  variant="ghost"
                  size="icon"
                  className="h-9 w-9 rounded-full hover:bg-[#e4e6eb]"
                >
                  <MapPin className="h-5 w-5 text-[#e94878]" />
                </Button>

                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button
                      variant="ghost"
                      size="icon"
                      className={`h-9 w-9 rounded-full hover:bg-[#e4e6eb] ${
                        selectedCategory ? "text-[#23c16b]" : "text-[#565973]"
                      }`}
                    >
                      <Tag className="h-5 w-5" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    {categories.map((category) => (
                      <DropdownMenuItem
                        key={category.id}
                        onClick={() => setSelectedCategory(category.id)}
                        className={
                          selectedCategory === category.id ? "bg-[#d7fae0]" : ""
                        }
                      >
                        {category.name}
                      </DropdownMenuItem>
                    ))}
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </div>
          )}

          <div
            className={`flex justify-end mt-4 ${
              isExpanded ? "flex-col gap-3" : ""
            }`}
          >
            {isExpanded && (
              <div className="flex gap-2 ml-auto">
                <Button
                  variant="outline"
                  className="rounded-lg text-[#565973] border-[#e4e6eb] hover:bg-[#f0f2f5]"
                  onClick={() => {
                    setIsExpanded(false);
                    setContent("");
                    setSelectedCategory(null);
                    setFiles([]);
                    setPreviews([]);
                  }}
                >
                  Cancel
                </Button>

                <Button
                  className="rounded-lg bg-[#23c16b] hover:bg-[#23c16b]/90 text-white px-6"
                  onClick={handleSubmit}
                  disabled={!content.trim() && files.length === 0}
                >
                  Post
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
              />
            </div>
          </div>

          <div
            className="mt-4 border-2 border-dashed border-[#e4e6eb] rounded-lg p-8 text-center cursor-pointer"
            onClick={handleFileSelect}
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
              />
            </div>
          </div>

          {previews.length > 0 && (
            <div className="mt-4 grid grid-cols-2 md:grid-cols-3 gap-2">
              {previews.map((src, index) => (
                <div
                  key={index}
                  className="relative rounded-lg overflow-hidden aspect-video bg-[#f0f2f5]"
                >
                  <Image
                    src={src || "/placeholder.svg"}
                    alt="Media"
                    width={500}
                    height={300}
                    className="object-cover w-full h-full"
                  />

                  <button
                    className="absolute top-2 right-2 bg-black/50 rounded-full p-1 hover:bg-black/70 transition-colors"
                    onClick={() => removeFile(index)}
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
              disabled={files.length === 0}
            >
              Post Photos
            </Button>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}
