"use client"

import { MoreVertical, Plus } from "lucide-react"
import { Button } from "@/components/ui/button"

export default function ConversationHeader() {
  return (
    <div className="p-4 border-b border-[#e2e8f0] flex items-center justify-between bg-white">
      <h1 className="text-xl font-semibold text-[#1e293b]">Messages</h1>
      <div className="flex gap-2">
        <Button variant="ghost" size="icon" className="rounded-full hover:bg-[#f1f5f9]">
          <Plus className="w-5 h-5 text-[#64748b]" />
        </Button>
        <Button variant="ghost" size="icon" className="rounded-full hover:bg-[#f1f5f9]">
          <MoreVertical className="w-5 h-5 text-[#64748b]" />
        </Button>
      </div>
    </div>
  )
}
