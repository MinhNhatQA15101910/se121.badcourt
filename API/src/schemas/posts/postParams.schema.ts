import { z } from "zod";

export const PostParamsSchema = z.object({
  pageNumber: z
    .preprocess((n) => parseFloat(z.string().parse(n)), z.number().min(0))
    .default("1"),
  pageSize: z
    .preprocess((n) => parseFloat(z.string().parse(n)), z.number().min(0))
    .default("10"),
  category: z.enum(["advertise", "findPlayer"]).optional(),
  sortBy: z.string().optional().default("createdAt"),
  order: z.string().optional().default("desc"),
});
