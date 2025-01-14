import mongoose from "mongoose";
import { FileSchema } from "../files/file.schema";
import ActiveSchema from "../active/active.schema";
import ManagerInfoSchema from "./managerInfo.schema";

const AppFacilitySchema = new mongoose.Schema({
  userId: {
    required: true,
    type: String,
    trim: true,
  },
  facilityName: {
    required: true,
    type: String,
    trim: true,
  },
  facebookUrl: {
    type: String,
    trim: true,
  },
  description: { type: String, trim: true, required: true },
  policy: { type: String, trim: true, required: true },
  courtsAmount: {
    type: Number,
    default: 0,
  },
  minPrice: {
    type: Number,
    default: 0,
  },
  maxPrice: {
    type: Number,
    default: 0,
  },
  detailAddress: {
    required: true,
    type: String,
    trim: true,
  },
  province: {
    required: true,
    type: String,
    trim: true,
  },
  location: {
    type: { type: String, enum: ["Point"], required: true },
    coordinates: { type: [Number], required: true },
  },
  ratingAvg: {
    type: Number,
    default: 0,
  },
  totalRating: {
    type: Number,
    default: 0,
  },
  activeAt: { type: ActiveSchema, default: null },
  createdAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
  facilityImages: [FileSchema],
  managerInfo: ManagerInfoSchema,
  state: {
    type: String,
    trim: true,
    default: "Pending",
  },
  updatedAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
});
AppFacilitySchema.index({ location: "2dsphere" });

export default AppFacilitySchema;
