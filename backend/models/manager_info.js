import mongoose from "mongoose";

import managerInfoSchema from "../schemas/manager_info_schema.js";

const ManagerInfo = mongoose.model("ManagerInfo", managerInfoSchema);

export default ManagerInfo;
