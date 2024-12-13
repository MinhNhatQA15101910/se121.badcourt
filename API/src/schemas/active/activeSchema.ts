import mongoose from "mongoose";
import TimePeriodSchema from "./timePeriodSchema";

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
