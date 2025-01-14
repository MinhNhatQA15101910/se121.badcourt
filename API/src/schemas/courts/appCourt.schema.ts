import mongoose from "mongoose";
import TimePeriodSchema from "../active/timePeriod.schema";

export const AppCourtSchema = new mongoose.Schema({
  facilityId: {
    required: true,
    type: String,
    trim: true,
  },
  courtName: {
    required: true,
    type: String,
    trim: true,
  },
  description: { type: String, trim: true, required: true },
  pricePerHour: {
    type: Number,
    default: 0,
  },
  state: {
    type: String,
    trim: true,
    default: "Active",
  },
  orderPeriods: [TimePeriodSchema],
  inactivePeriods: [TimePeriodSchema],
  orders: [String],
  createdAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
  updatedAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
});
