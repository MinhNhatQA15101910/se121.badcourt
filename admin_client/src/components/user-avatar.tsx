import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import type { User } from "@/lib/types"

interface UserAvatarProps {
  user: User
  size?: "xs" | "sm" | "md" | "lg"
  showStatus?: boolean
  showBorder?: boolean
}

export function UserAvatar({ user, size = "md", showStatus = false, showBorder = false }: UserAvatarProps) {
  const sizeClasses = {
    xs: "h-6 w-6",
    sm: "h-8 w-8",
    md: "h-10 w-10",
    lg: "h-14 w-14",
  }

  const borderClass = showBorder ? "border-2 border-[#23c16b]" : ""

  return (
    <div className="relative">
      <Avatar className={`${sizeClasses[size]} ${borderClass}`}>
        <AvatarImage src={user.avatar} alt={user.name} />
        <AvatarFallback>
          {user.name.charAt(0)}
          {user.name.split(" ").pop()?.charAt(0)}
        </AvatarFallback>
      </Avatar>

      {showStatus && (
        <div
          className={`absolute bottom-0 right-0 rounded-full border-2 border-white ${user.isOnline ? "bg-[#23c16b]" : "bg-[#9397ad]"}`}
          style={{
            width: size === "xs" ? "6px" : size === "sm" ? "8px" : size === "md" ? "10px" : "12px",
            height: size === "xs" ? "6px" : size === "sm" ? "8px" : size === "md" ? "10px" : "12px",
          }}
        ></div>
      )}
    </div>
  )
}

