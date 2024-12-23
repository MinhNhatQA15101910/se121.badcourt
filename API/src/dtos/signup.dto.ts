export interface SignupDto {
  username: string;
  email: string;
  password: string;
  role: "player" | "manager";
  imageUrl?: string | undefined;
}
