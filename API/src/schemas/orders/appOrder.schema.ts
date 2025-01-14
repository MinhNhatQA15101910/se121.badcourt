import mongoose from "mongoose";
import { FileSchema } from "../files/file.schema";
import TimePeriodSchema from "../active/timePeriod.schema";

export const AppOrderSchema = new mongoose.Schema({
  userId: {
    required: true,
    type: String,
    trim: true,
  },
  courtId: {
    required: true,
    type: String,
    trim: true,
  },
  address: {
    required: true,
    type: String,
    trim: true,
  },
  timePeriod: { type: TimePeriodSchema, required: true },
  price: {
    type: Number,
    default: 0,
  },
  state: {
    type: String,
    trim: true,
    default: "Not play",
  },
  image: { type: FileSchema, default: null },
  facilityName: { type: String, trim: true, required: true },
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
