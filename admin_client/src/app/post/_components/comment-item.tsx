"use client";
import { formatDistanceToNow } from "date-fns";
import { UserAvatar } from "./user-avatar";
import type { Comment } from "@/lib/types";
import { MoreHorizontal, ThumbsUp } from "lucide-react";
import Image from "next/image";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";

interface CommentItemProps {
  comment: Comment;
  postId: string;
  onLike: (commentId: string) => void;
}

export default function CommentItem({ comment, onLike }: CommentItemProps) {
  const handleLike = () => {
    onLike(comment.id);
  };

  // Map resources to mediaUrls for compatibility with the UI
  const mediaUrls = comment.resources
    ? comment.resources
        .filter((resource) => resource.fileType === "Image")
        .map((resource) => resource.url)
    : [];

  return (
    <div className="flex gap-3">
      <UserAvatar
        user={{
          id: comment.publisherId,
          username: comment.publisherUsername,
          email: comment.publisherImageUrl,
          photoUrl: comment.publisherImageUrl,
          token: "",
          roles: [],
          isOnline: false,
          verified: false,
        }}
        size="sm"
      />
      <div className="flex-1">
        <div className="bg-[#f0f2f5] rounded-lg p-3 relative group">
          <div className="flex justify-between">
            <span className="font-semibold text-[#0b0f19]">
              {comment.publisherUsername}
            </span>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-6 w-6 rounded-full absolute right-2 top-2 opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  <MoreHorizontal className="h-4 w-4 text-[#565973]" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem className="cursor-pointer">
                  Copy text
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem className="cursor-pointer text-red-500">
                  Report
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
          <p className="text-[#0b0f19] whitespace-pre-line">
            {comment.content}
          </p>

          {mediaUrls.length > 0 && (
            <div className="mt-2">
              {mediaUrls.map((url, index) => (
                <Image
                  key={index}
                  src={url || "/placeholder.svg"}
                  alt="Comment attachment"
                  width={400} // hoặc bất kỳ kích thước phù hợp
                  height={160}
                  className="max-w-full rounded-lg mt-1 max-h-40 object-contain"
                />
              ))}
            </div>
          )}
        </div>
        <div className="flex items-center gap-4 mt-1 ml-2 text-xs">
          <button
            className={`flex items-center font-medium ${
              comment.isLiked ? "text-[#23c16b]" : "text-[#565973]"
            }`}
            onClick={handleLike}
          >
            <ThumbsUp
              className={`h-3.5 w-3.5 mr-1 ${
                comment.isLiked ? "fill-[#23c16b]" : ""
              }`}
            />
            <span>Like</span>
            {comment.likesCount > 0 && (
              <span className="ml-1">· {comment.likesCount}</span>
            )}
          </button>
          <span className="text-[#565973]">
            {formatDistanceToNow(new Date(comment.createdAt), {
              addSuffix: true,
            })}
          </span>
        </div>
      </div>
    </div>
  );
}
