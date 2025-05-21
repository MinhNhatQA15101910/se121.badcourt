import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import type { User } from "@/lib/types"

interface UserAvatarProps {
  user: Partial<User>
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

  // Get initials from username
  const getInitials = () => {
    if (!user.username) return "U"
    const nameParts = user.username.split(" ")
    if (nameParts.length === 1) return nameParts[0].charAt(0).toUpperCase()
    return (nameParts[0].charAt(0) + nameParts[nameParts.length - 1].charAt(0)).toUpperCase()
  }

  // Determine status indicator size based on avatar size
  const getStatusSize = () => {
    switch (size) {
      case "xs":
        return { width: "6px", height: "6px" }
      case "sm":
        return { width: "8px", height: "8px" }
      case "md":
        return { width: "10px", height: "10px" }
      case "lg":
        return { width: "12px", height: "12px" }
      default:
        return { width: "10px", height: "10px" }
    }
  }

  const statusSize = getStatusSize()

  return (
    <div className="relative">
      <Avatar className={`${sizeClasses[size]} ${borderClass}`}>
        <AvatarImage src={user.photoUrl || "/placeholder.svg"} alt={user.username || "User"} />
        <AvatarFallback>{getInitials()}</AvatarFallback>
      </Avatar>

      {showStatus && (
        <div
          className={`absolute bottom-0 right-0 rounded-full border-2 border-white ${user.isOnline ? "bg-[#23c16b]" : "bg-[#9397ad]"}`}
          style={{
            width: statusSize.width,
            height: statusSize.height,
          }}
        />
      )}
    </div>
  )
}
