import { Router } from "express";
import authRoutes from "./authRoutes";
import userRoutes from "./userRoutes";
import facilityRoutes from "./facilityRoutes";
import postRoutes from "./postRoutes";

const rootRouter: Router = Router();

rootRouter.use("/auth", authRoutes);
rootRouter.use("/facilities", facilityRoutes);
rootRouter.use("/posts", postRoutes);
rootRouter.use("/users", userRoutes);

export default rootRouter;
