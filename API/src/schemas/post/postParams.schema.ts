import { z } from "zod";

export const PostParamsSchema = z.object({
  pageNumber: z.number().int().min(1).default(1),
  pageSize: z.number().int().min(1).default(10),
  category: z.enum(["advertise", "findPlayer"]).optional(),
  sortBy: z.string().optional().default("createdAt"),
  order: z.string().optional().default("desc"),
});
