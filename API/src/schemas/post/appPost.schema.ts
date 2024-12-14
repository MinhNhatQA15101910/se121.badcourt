import mongoose from "mongoose";
import { FileSchema } from "../file/file.schema";

export const AppPostSchema = new mongoose.Schema({
  userId: {
    required: true,
    type: String,
    trim: true,
  },
  title: { type: String, trim: true, required: true },
  description: { type: String, trim: true, required: true },
  category: { type: String, trim: true, default: "advertise" },
  resources: [FileSchema],
  createdAt: {
    type: Number,
    require: true,
    default: Date.now(),
  },
  updatedAt: {
    type: Number,
    require: true,
    default: Date.now(),
  },
});
