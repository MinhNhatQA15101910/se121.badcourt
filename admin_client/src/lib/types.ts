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

export interface MessageDto {
  id: string
  groupId: string
  senderId: string
  senderUsername: string
  senderImageUrl: string
  receiverId: string
  content: string
  dateRead?: string
  messageSent: string
  resources: FileDto[]
}

export interface GroupDto {
  id: string
  name: string
  users: UserDto[]
  lastMessage?: MessageDto
  connections: ConnectionDto[]
  updatedAt: string
}

// Frontend types for UI components
export interface MessageType {
  id: string
  text: string
  time: string
  sent: boolean
  imageUrl?: string
  hasImage?: boolean
  recipientId?: string
  senderId?: string
  senderUsername?: string
  senderImageUrl?: string
  resources?: FileDto[]
  groupId?: string
}

export interface ConversationType {
  id: string
  name: string
  avatar: string
  lastMessage: string
  time: string
  unread: number
  online: boolean
  starred?: boolean
  messages: MessageType[]
  userId?: string
  groupId?: string
  isGroup?: boolean
  users?: UserDto[]
  pagination?: PaginationState
}

// SignalR specific types - Use type aliases instead of empty interfaces
export type SignalRMessage = MessageDto

export type SignalRGroup = GroupDto

// Callback interfaces with pagination support
export interface PresenceCallbacks {
  onUserOnline?: (userId: string) => void
  onUserOffline?: (userId: string) => void
  onOnlineUsers?: (users: string[]) => void
}

export interface MessageCallbacks {
  onReceiveMessageThread?: (messages: SignalRMessageThread) => void
  onNewMessage?: (message: SignalRMessage) => void
  onMessageRead?: (messageId: string, userId: string) => void
}

export interface GroupCallbacks {
  onReceiveGroups?: (groups: SignalRGroupList) => void
  onJoinedGroup?: (group: SignalRGroup) => void
  onLeftGroup?: (groupId: string) => void
  onGroupUpdated?: (group: SignalRGroup) => void
  onUserJoinedGroup?: (groupId: string, user: UserDto) => void
  onUserLeftGroup?: (groupId: string, userId: string) => void
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
