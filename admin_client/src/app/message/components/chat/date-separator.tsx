"use client"

interface DateSeparatorProps {
  date: string
}

export default function DateSeparator({ date }: DateSeparatorProps) {
  return (
    <div className="flex items-center justify-center gap-4 my-4">
      <div className="h-[1px] bg-[#cbd5e1] flex-1 opacity-70"></div>
      <span className="text-xs font-medium text-[#64748b] px-3 py-1 bg-[#f1f5f9] rounded-full">{date}</span>
      <div className="h-[1px] bg-[#cbd5e1] flex-1 opacity-70"></div>
    </div>
  )
}

