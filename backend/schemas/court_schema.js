import mongoose from "mongoose";

import timePeriodSchema from "./time_period_schema.js";

const courtSchema = mongoose.Schema({
  facility_id: {
    required: true,
    type: String,
    trim: true,
  },
  name: {
    required: true,
    type: String,
    trim: true,
  },
  description: {
    required: true,
    type: String,
    trim: true,
  },
  price_per_hour: {
    required: true,
    type: Number,
  },
  order_periods: [timePeriodSchema],
  inactive_periods: [timePeriodSchema],
});

export default courtSchema;
