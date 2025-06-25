// Pagination types matching backend PagedList<T>
export interface PagedList<T> {
  currentPage: number
  totalPages: number
  pageSize: number
  totalCount: number
  items: T[]
}

// Updated SignalR response types
export interface SignalRMessageThread {
  currentPage: number
  totalPages: number
  pageSize: number
  totalCount: number
  items: SignalRMessage[]
}

export interface SignalRGroupList {
  currentPage: number
  totalPages: number
  pageSize: number
  totalCount: number
  items: SignalRGroup[]
}

// Pagination state for UI
export interface PaginationState {
  currentPage: number
  totalPages: number
  pageSize: number
  totalCount: number
  hasNextPage: boolean
  hasPreviousPage: boolean
  isLoading: boolean
}

// Updated types to match backend DTOs
export interface FileDto {
  id: string
  url: string
  fileName: string
  fileType: string
  fileSize: number
}

export interface UserDto {
  id: string
  username: string
  email: string
  photoUrl: string
  isOnline?: boolean
}

export interface ConnectionDto {
  id: string
  userId: string
  userAgent: string
  connected: boolean
}

// Frontend types for UI components
export interface MessageType {
  id: string | number
  text: string
  time: string
  sent: boolean
  senderId?: string
  recipientId?: string
  senderUsername?: string
  senderImageUrl?: string
  resources?: Array<{
    id: string
    url: string
    fileName?: string
    fileType?: string
    fileSize?: number
  }>
  groupId?: string
  imageUrl?: string
  hasImage?: boolean
}

export interface ConversationType {
  id: string
  name: string
  avatar: string
  lastMessage: string
  time: string
  unread: number
  online: boolean
  starred: boolean
  messages?: MessageType[]
  groupId?: string
  isGroup?: boolean
  users?: Array<{
    id: string
    username: string
    photoUrl?: string
  }>
  userId?: string
}

// SignalR specific types - Use type aliases instead of empty interfaces
export interface SignalRMessage {
  id: string
  groupId?: string
  senderId: string
  senderUsername: string
  senderImageUrl?: string
  receiverId: string
  content: string
  dateRead?: string
  messageSent: string
  resources?: Array<{
    id: string
    url: string
    fileName?: string
    fileType?: string
    fileSize?: number
  }>
}

export interface SignalRGroup {
  id: string
  name: string
  users: Array<{
    id: string
    username: string
    photoUrl?: string
  }>
  connections: Array<{
    connectionId: string
    userId: string
    connected: boolean
  }>
  lastMessage?: {
    id: string
    content: string
    messageSent: string
    senderUsername: string
    senderId: string
    dateRead?: string | null
  }
  createdAt: string
  updatedAt: string
}

// Callback interfaces with pagination support
export interface PresenceCallbacks {
  onUserOnline?: (userId: string) => void
  onUserOffline?: (userId: string) => void
  onOnlineUsers?: (users: string[]) => void
}

export interface MessageCallbacks {
  onReceiveMessageThread?: (messageThread: SignalRMessageThread) => void
  onNewMessage?: (message: SignalRMessage) => void
}

export interface GroupCallbacks {
  onReceiveGroups?: (groupList: SignalRGroupList) => void
  onNewMessageReceived?: (groupDto: SignalRGroup) => void
}

// Legacy types for backward compatibility
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
  username: string
  email: string
  token: string
  roles: string[]
  photoUrl: string
  isOnline?: boolean
  verified?: boolean
}

export type UpdateUserParams = Partial<Omit<User, "id" | "token">>

export interface LoginCredentials {
  email: string
  password: string
}

export interface Resource {
  id: string | null
  url: string
  isMain: boolean
  fileType: string
}

export interface Post {
  id: string
  publisherId: string
  publisherUsername: string
  publisherImageUrl: string
  title: string
  content: string
  category: string
  resources: Resource[]
  likesCount: number
  commentsCount: number
  isLiked: boolean
  createdAt: string
}

export interface CreatePostParams {
  title: string
  content: string
  category: string
  resources?: File[]
}

export interface Comment {
  id: string
  publisherId: string
  postId: string
  publisherUsername: string
  publisherImageUrl: string
  content: string
  resources: Resource[]
  likesCount: number
  isLiked: boolean
  createdAt: string
}

export interface CreateCommentParams {
  postId: string
  content: string
  resources?: File[]
}
