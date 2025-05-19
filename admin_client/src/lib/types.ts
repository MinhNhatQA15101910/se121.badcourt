// Define types for our data models

export interface Owner {
    id: number
    ownerName: string
    ownerImage: string
    ownerEmail: string
    ownerId: string
    ownerAddress: string
    numberOfFacilities: number
    totalRevenue: number
    status: "Activated" | "Deactivated"
    province: string
    district: string
    phoneNumber: string
    gender: string
  }
  
  export interface Facility {
    id: number
    facilityName: string
    facilityImage: string
    facilityAddress: string
    facilityId: string
    ownerName: string
    ownerEmail: string
    ownerId: string
    registerDate: string
    status: "Active" | "Pending" | "Inactive"
    province: string
    district: string
    revenue: number
  }
  
  export interface FilterValues {
    province: string
    district: string
    status: string
    searchTerm: string
  }

// Định nghĩa User interface
export interface User {
  id: string
  username: string
  email: string
  token: string
  roles: string[] // Chỉ giữ lại mảng roles
  photoUrl: string
  isOnline?: boolean
  verified?: boolean
}

// Type cho các tham số cập nhật user
export type UpdateUserParams = Partial<Omit<User, "id" | "token">>

// Type cho thông tin đăng nhập
export interface LoginCredentials {
  email: string
  password: string
}

  
  export interface Comment {
    id: string
    author: User
    content: string
    createdAt: Date
    likes: number
    isLiked: boolean
    replies?: Comment[]
  }
  
  export interface Post {
    id: string
    author: User
    title?: string
    content: string
    category?: string
    mediaUrls?: string[]
    createdAt: Date
    likes: number
    comments: Comment[]
    isLiked: boolean
    shares: number
    bookmarked: boolean
    privacy?: "public" | "friends" | "private"
  }


export interface ConversationType {
  id: number
  name: string
  avatar: string
  lastMessage: string
  time: string
  unread: number
  online: boolean
  isActive: boolean
  starred: boolean
  messages: MessageType[]
}

export interface MessageType {
  id: number
  text: string
  sent: boolean
  time: string
  hasImage?: boolean
  imageUrl?: string
}




  
  
  
  