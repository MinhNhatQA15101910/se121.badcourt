import mongoose from "mongoose";

import courtSchema from "../schemas/court_schema.js";

const Court = mongoose.model("Court", courtSchema);

export default Court;
