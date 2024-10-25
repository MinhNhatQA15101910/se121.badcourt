import { Container } from "inversify";
import { IFacilityRepository } from "../interfaces/repositories/IFacilityRepository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { FacilityRepository } from "../repositories/facilityRepository";
import { FacilityController } from "../controllers/facilityController";
import { Router } from "express";
import { authMiddleware } from "../middlewares/authMiddleware";
import { errorHandler } from "../errorHandler";
import { upload } from "../middlewares/multerMiddleware";

const container = new Container();

container
  .bind<IFacilityRepository>(INTERFACE_TYPE.FacilityRepository)
  .to(FacilityRepository);

container.bind(INTERFACE_TYPE.FacilityController).to(FacilityController);

const facilityRoutes: Router = Router();

const facilityController = container.get<FacilityController>(
  INTERFACE_TYPE.FacilityController
);

// userRoutes.get(
//   "/",
//   [authMiddleware],
//   errorHandler(facilityController.getFacilities.bind(facilityController))
// );

facilityRoutes.post(
  "/upload-file",
  [authMiddleware],
  upload.single("file"),
  errorHandler(facilityController.uploadFile.bind(facilityController))
);

export default facilityRoutes;
