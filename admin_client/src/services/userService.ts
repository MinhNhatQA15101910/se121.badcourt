import { fetchApi } from "./api"
import type { User } from "@/lib/types" // Đảm bảo đường dẫn import đúng

// Định nghĩa type cho tham số cập nhật user (nếu chưa có trong lib/types.ts)
type UpdateUserParams = Partial<Omit<User, "id" | "token">>

export const userService = {
  getUsers: () => fetchApi<User[]>("/users"),

  getUserById: (id: string) => fetchApi<User>(`/users/${id}`),

  createUser: (userData: Omit<User, "id" | "token">) =>
    fetchApi<User>("/users", {
      method: "POST",
      body: JSON.stringify(userData),
    }),

  updateUser: (id: string, userData: UpdateUserParams) =>
    fetchApi<User>(`/users/${id}`, {
      method: "PUT",
      body: JSON.stringify(userData),
    }),

  deleteUser: (id: string) =>
    fetchApi<void>(`/users/${id}`, {
      method: "DELETE",
    }),
}
