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
  name: {
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
  activeAt: ActiveSchema,
  registeredAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
  facilityImages: [FileSchema],
  managerInfo: ManagerInfoSchema,
  isApproved: {
    type: Boolean,
    default: false,
  },
  approvedAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
  chatRooms: [{ type: String }],
});
AppFacilitySchema.index({ location: "2dsphere" });

export default AppFacilitySchema;
