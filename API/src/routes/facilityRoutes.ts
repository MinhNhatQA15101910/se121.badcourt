import { Container } from "inversify";
import { IFacilityRepository } from "../interfaces/repositories/IFacilityRepository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { FacilityRepository } from "../repositories/facilityRepository";
import { FacilityController } from "../controllers/facilityController";
import { Router } from "express";
import { authMiddleware } from "../middlewares/authMiddleware";
import { errorHandler } from "../errorHandler";

const container = new Container();

container
  .bind<IFacilityRepository>(INTERFACE_TYPE.FacilityRepository)
  .to(FacilityRepository);

container.bind(INTERFACE_TYPE.FacilityController).to(FacilityController);

const userRoutes: Router = Router();

const facilityController = container.get<FacilityController>(
  INTERFACE_TYPE.FacilityController
);

userRoutes.get(
  "/",
  [authMiddleware],
  errorHandler(facilityController.getFacilities.bind(facilityController))
);

export default userRoutes;
