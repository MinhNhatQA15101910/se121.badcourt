"use client"

import { Search } from "lucide-react"

interface EmptySearchResultProps {
  searchQuery: string
}

export default function EmptySearchResult({ searchQuery }: EmptySearchResultProps) {
  return (
    <div className="flex flex-col items-center justify-center h-full p-4">
      <div className="w-16 h-16 bg-[#f8f9fd] rounded-full flex items-center justify-center mb-4">
        <Search className="w-8 h-8 text-[#9fa7be]" />
      </div>
      <p className="text-[#64748b] text-center">
        {searchQuery ? `No results found for "${searchQuery}"` : "No messages found"}
      </p>
    </div>
  )
}
