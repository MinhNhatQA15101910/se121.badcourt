import mongoose from "mongoose";

import facilitySchema from "../schemas/facility_schema.js";

const Facility = mongoose.model("Facility", facilitySchema);

export default Facility;
