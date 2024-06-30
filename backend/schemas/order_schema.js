import mongoose from "mongoose";

import timePeriodSchema from "./time_period_schema.js";

const orderSchema = mongoose.Schema({
  user_id: {
    required: true,
    type: String,
    trim: true,
  },
  court_id: {
    required: true,
    type: String,
    trim: true,
  },
  ordered_at: {
    type: Number,
    required: true,
  },
  facility_name: {
    required: true,
    type: String,
    trim: true,
  },
  address: {
    required: true,
    type: String,
    trim: true,
  },
  period: {
    required: true,
    type: timePeriodSchema,
  },
  price: {
    required: true,
    type: Number,
  },
});

export default orderSchema;
