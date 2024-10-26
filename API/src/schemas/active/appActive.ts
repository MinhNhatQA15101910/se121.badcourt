import mongoose from "mongoose";

const TimePeriodSchema = new mongoose.Schema({
  userId: {
    type: String,
    trim: true,
  },
  hourFrom: {
    type: Number,
    required: true,
    default: 0,
  },
  hourTo: {
    type: Number,
    required: true,
    default: 0,
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
