"use client"

interface ConversationTabsProps {
  activeTab: string
  onTabChange: (tab: string) => void
}

export default function ConversationTabs({ activeTab, onTabChange }: ConversationTabsProps) {
  const tabs = [
    { id: "all", label: "All" },
    { id: "unread", label: "Unread" },
    { id: "starred", label: "Starred" },
  ]

  return (
    <div className="flex px-4 border-b border-[#e5e7eb]">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          className={`py-3 px-4 text-sm font-medium transition-colors relative ${
            activeTab === tab.id ? "text-[#23c16b]" : "text-[#64748b] hover:text-[#334155]"
          }`}
          onClick={() => onTabChange(tab.id)}
        >
          {tab.label}
          {activeTab === tab.id && <div className="absolute bottom-0 left-0 right-0 h-[2px] bg-[#23c16b]"></div>}
        </button>
      ))}
    </div>
  )
}

