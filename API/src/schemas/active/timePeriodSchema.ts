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

export default TimePeriodSchema;
