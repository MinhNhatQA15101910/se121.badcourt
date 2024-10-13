import { Router } from "express";
import authRoutes from "./authRoutes";
import userRoutes from "./userRoutes";
import facilityRoutes from "./facilityRoutes";

const rootRouter: Router = Router();

rootRouter.use("/auth", authRoutes);
rootRouter.use("/facilities", facilityRoutes);
rootRouter.use("/users", userRoutes);

export default rootRouter;
