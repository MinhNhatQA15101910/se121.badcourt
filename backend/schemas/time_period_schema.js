import mongoose from "mongoose";

const timePeriodSchema = mongoose.Schema({
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

export default timePeriodSchema;
