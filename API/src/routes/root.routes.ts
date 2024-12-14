import { Router } from "express";
import authRoutes from "./auth.routes";
import userRoutes from "./user.routes";
import facilityRoutes from "./facility.routes";
import postRoutes from "./post.routes";

const rootRoutes: Router = Router();

rootRoutes.use("/auth", authRoutes);
rootRoutes.use("/facilities", facilityRoutes);
rootRoutes.use("/posts", postRoutes);
rootRoutes.use("/users", userRoutes);

export default rootRoutes;
