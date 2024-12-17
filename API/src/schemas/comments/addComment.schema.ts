import { z } from "zod";

export const AddCommentSchema = z.object({
  postId: z.string(),
  content: z.string(),
});
