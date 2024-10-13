import mongoose from "mongoose";

const TimePeriodSchema = new mongoose.Schema({
  user_id: {
    type: String,
    trim: true,
  },
  hour_from: {
    type: Number,
    required: true,
  },
  hour_to: {
    type: Number,
    required: true,
  },
});

const ActiveSchema = new mongoose.Schema({
  monday: TimePeriodSchema,
  tuesday: TimePeriodSchema,
  wednesday: TimePeriodSchema,
  thursday: TimePeriodSchema,
  friday: TimePeriodSchema,
  saturday: TimePeriodSchema,
  sunday: TimePeriodSchema,
});

export default ActiveSchema;
