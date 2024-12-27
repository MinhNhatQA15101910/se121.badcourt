import { z } from "zod";

export const UserParamsSchema = z.object({
  pageNumber: z
    .preprocess((n) => parseFloat(z.string().parse(n)), z.number().min(0))
    .default("1"),
  pageSize: z
    .preprocess((n) => parseFloat(z.string().parse(n)), z.number().min(0))
    .default("10"),
  username: z.string().optional(),
  email: z.string().optional(),
  role: z.string().optional(),
  sortBy: z.string().optional().default("username"),
  order: z.string().optional().default("asc"),
});
