import { z } from "zod";

export const MessageRoomParamsSchema = z.object({
  pageNumber: z
    .preprocess((n) => parseFloat(z.string().parse(n)), z.number().min(0))
    .default("1"),
  pageSize: z
    .preprocess((n) => parseFloat(z.string().parse(n)), z.number().min(0))
    .default("10"),
  userId: z.string().optional(),
});
