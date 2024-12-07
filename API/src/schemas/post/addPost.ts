import { z } from "zod";

export const AddPostSchema = z.object({
  title: z.string(),
  description: z.string(),
  category: z.enum(["advertise", "findPlayer"]).default("advertise"),
});
