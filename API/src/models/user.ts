import mongoose from "mongoose";
import { AppUserSchema } from "../schemas/user/appUserSchema";

const User = mongoose.model("User", AppUserSchema);

export default User;
