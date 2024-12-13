import mongoose from "mongoose";
import AppFacilitySchema from "../schemas/facility/appFacilitySchema";

const Facility = mongoose.model("Facility", AppFacilitySchema);

export default Facility;
