import mongoose from "mongoose";
import AppFacilitySchema from "../schemas/facilities/appFacility.schema";

const Facility = mongoose.model("Facility", AppFacilitySchema);

export default Facility;
