// Define types for our data models

export interface Owner {
  id: number;
  ownerName: string;
  ownerImage: string;
  ownerEmail: string;
  ownerId: string;
  ownerAddress: string;
  numberOfFacilities: number;
  totalRevenue: number;
  status: "Activated" | "Deactivated";
  province: string;
  district: string;
  phoneNumber: string;
  gender: string;
}

export interface Facility {
  id: number;
  facilityName: string;
  facilityImage: string;
  facilityAddress: string;
  facilityId: string;
  ownerName: string;
  ownerEmail: string;
  ownerId: string;
  registerDate: string;
  status: "Active" | "Pending" | "Inactive";
  province: string;
  district: string;
  revenue: number;
}

export interface FilterValues {
  province: string;
  district: string;
  status: string;
  searchTerm: string;
}

// Định nghĩa User interface
export interface User {
  id: string;
  username: string;
  email: string;
  token: string;
  roles: string[]; // Chỉ giữ lại mảng roles
  photoUrl: string;
  isOnline?: boolean;
  verified?: boolean;
}

// Type cho các tham số cập nhật user
export type UpdateUserParams = Partial<Omit<User, "id" | "token">>;

// Type cho thông tin đăng nhập
export interface LoginCredentials {
  email: string;
  password: string;
}

// Định nghĩa Resource interface cho các tài nguyên đa phương tiện
export interface Resource {
  id: string | null;
  url: string;
  isMain: boolean;
  fileType: string;
}

// Cập nhật Post interface theo mẫu dữ liệu mới
export interface Post {
  id: string;
  publisherId: string;
  publisherUsername: string;
  publisherImageUrl: string;
  title: string;
  content: string;
  category: string;
  resources: Resource[];
  likesCount: number;
  commentsCount: number;
  isLiked: boolean;
  createdAt: string;
}

// Type cho tham số tạo bài đăng mới
export interface CreatePostParams {
  title: string;
  content: string;
  category: string;
  resources?: File[]; // Sử dụng File cho upload
}

// Cập nhật interface Comment theo mẫu dữ liệu mới
export interface Comment {
  id: string;
  publisherId: string;
  postId: string;
  publisherUsername: string;
  publisherImageUrl: string;
  content: string;
  resources: Resource[];
  likesCount: number;
  isLiked: boolean;
  createdAt: string;
}

// Type cho tham số tạo comment mới
export interface CreateCommentParams {
  postId: string;
  content: string;
  resources?: File[]; // Sử dụng File cho upload
}

export interface MessageType {
  id: string | number
  text: string
  time: string
  sent: boolean
  imageUrl?: string
  hasImage?: boolean
  recipientId?: string
  senderId?: string
}

export interface ConversationType {
  id: string | number
  name: string
  avatar: string
  lastMessage: string
  time: string
  unread: number
  online: boolean
  starred?: boolean
  messages: MessageType[]
  userId?: string
}

export interface SignalRMessage {
  id: string
  senderId: string
  recipientId: string
  content: string
  dateRead?: string
  messageSent: string
  senderUsername?: string
  senderPhotoUrl?: string
}

// New interfaces for SignalR message thread
export interface SignalRMessageThread {
  messages: SignalRMessage[]
  pagination?: {
    currentPage: number
    itemsPerPage: number
    totalItems: number
    totalPages: number
  }
}

// Type for SignalR callbacks
export interface PresenceCallbacks {
  onUserOnline?: (userId: string) => void
  onUserOffline?: (userId: string) => void
  onOnlineUsers?: (users: string[]) => void
}

export interface MessageCallbacks {
  onReceiveMessageThread?: (messages: SignalRMessageThread) => void
  onNewMessage?: (message: SignalRMessage) => void
}

