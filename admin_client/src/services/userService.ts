import { fetchWithAuth } from "./api"
import type { User } from "@/lib/types" // Đảm bảo đường dẫn import đúng

// Định nghĩa type cho tham số cập nhật user (nếu chưa có trong lib/types.ts)
type UpdateUserParams = Partial<Omit<User, "id" | "token">>

export const userService = {
  getUsers: () => fetchWithAuth<User[]>("/users"),

  getUserById: (id: string) => fetchWithAuth<User>(`/users/${id}`),

  createUser: (userData: Omit<User, "id" | "token">) =>
    fetchWithAuth<User>("/users", {
      method: "POST",
      body: JSON.stringify(userData),
    }),

  updateUser: (id: string, userData: UpdateUserParams) =>
    fetchWithAuth<User>(`/users/${id}`, {
      method: "PUT",
      body: JSON.stringify(userData),
    }),

  deleteUser: (id: string) =>
    fetchWithAuth<void>(`/users/${id}`, {
      method: "DELETE",
    }),
}
