import mongoose from "mongoose";
import AppFacilitySchema from "../schemas/facility/appFacility";

const Facility = mongoose.model("Facility", AppFacilitySchema);

export default Facility;
