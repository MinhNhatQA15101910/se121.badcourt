import mongoose from "mongoose";
import { AppCourtSchema } from "../schemas/courts/appCourt.schema";

const Court = mongoose.model("Court", AppCourtSchema);

export default Court;
