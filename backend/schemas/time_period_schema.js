import mongoose from "mongoose";

const timePeriodSchema = mongoose.Schema({
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
