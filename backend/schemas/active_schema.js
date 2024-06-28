import mongoose from "mongoose";

import timePeriodSchema from "./time_period_schema.js";

const activeSchema = mongoose.Schema({
  monday: timePeriodSchema,
  tuesday: timePeriodSchema,
  wednesday: timePeriodSchema,
  thursday: timePeriodSchema,
  friday: timePeriodSchema,
  saturday: timePeriodSchema,
  sunday: timePeriodSchema,
});

export default activeSchema;
