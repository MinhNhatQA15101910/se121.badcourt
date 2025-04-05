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

  export interface User {
    id: string
    name: string
    avatar: string
    role?: string
    isOnline?: boolean
    verified?: boolean
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
  
  
  
  