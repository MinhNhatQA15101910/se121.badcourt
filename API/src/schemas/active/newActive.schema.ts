import { z } from "zod";

export const NewActiveSchema = z.object({
  monday: z.object({
    hourFrom: z.number().int().min(0),
    hourTo: z.number().int(),
  }),
  tuesday: z.object({
    hourFrom: z.number().int().min(0),
    hourTo: z.number().int(),
  }),
  wednesday: z.object({
    hourFrom: z.number().int().min(0),
    hourTo: z.number().int(),
  }),
  thursday: z.object({
    hourFrom: z.number().int().min(0),
    hourTo: z.number().int(),
  }),
  friday: z.object({
    hourFrom: z.number().int().min(0),
    hourTo: z.number().int(),
  }),
  saturday: z.object({
    hourFrom: z.number().int().min(0),
    hourTo: z.number().int(),
  }),
  sunday: z.object({
    hourFrom: z.number().int().min(0),
    hourTo: z.number().int(),
  }),
});
