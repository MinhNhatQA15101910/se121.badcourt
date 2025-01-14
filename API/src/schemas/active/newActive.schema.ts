import { z } from "zod";

export const NewActiveSchema = z.object({
  monday: z
    .object({
      hourFrom: z.number().int().min(0),
      hourTo: z.number().int(),
    })
    .optional(),
  tuesday: z
    .object({
      hourFrom: z.number().int().min(0),
      hourTo: z.number().int(),
    })
    .optional(),
  wednesday: z
    .object({
      hourFrom: z.number().int().min(0),
      hourTo: z.number().int(),
    })
    .optional(),
  thursday: z
    .object({
      hourFrom: z.number().int().min(0),
      hourTo: z.number().int(),
    })
    .optional(),
  friday: z
    .object({
      hourFrom: z.number().int().min(0),
      hourTo: z.number().int(),
    })
    .optional(),
  saturday: z
    .object({
      hourFrom: z.number().int().min(0),
      hourTo: z.number().int(),
    })
    .optional(),
  sunday: z
    .object({
      hourFrom: z.number().int().min(0),
      hourTo: z.number().int(),
    })
    .optional(),
});
