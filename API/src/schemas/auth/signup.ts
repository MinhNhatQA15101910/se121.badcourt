import { z } from "zod";

export interface SignupDto {
  username: string;
  email: string;
  password: string;
  role: "player" | "manager";
  imageUrl?: string | undefined;
}

export const SignupSchema = z.object({
  username: z.string().min(6),
  email: z.string().email(),
  password: z.string().min(8).max(50),
  imageUrl: z.string().optional(),
  role: z.enum(["player", "manager"]).default("player"),
});
