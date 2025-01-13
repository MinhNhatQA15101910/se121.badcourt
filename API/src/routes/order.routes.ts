import { Container } from "inversify";
import { IOrderRepository } from "../interfaces/repositories/IOrder.repository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { OrderRepository } from "../repositories/order.repository";
import { OrderController } from "../controllers/order.controller";
import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware";
import { errorHandler } from "../errorHandler";
import { ICourtRepository } from "../interfaces/repositories/ICourt.repository";
import { CourtRepository } from "../repositories/court.repositoryt";
import { IFacilityRepository } from "../interfaces/repositories/IFacility.repository";
import { FacilityRepository } from "../repositories/facility.repository";

const container = new Container();

container
  .bind<ICourtRepository>(INTERFACE_TYPE.CourtRepository)
  .to(CourtRepository);
container
  .bind<IFacilityRepository>(INTERFACE_TYPE.FacilityRepository)
  .to(FacilityRepository);
container
  .bind<IOrderRepository>(INTERFACE_TYPE.OrderRepository)
  .to(OrderRepository);

container.bind(INTERFACE_TYPE.OrderController).to(OrderController);

const orderRoutes: Router = Router();

const orderController = container.get<OrderController>(
  INTERFACE_TYPE.OrderController
);

orderRoutes.post(
  "/",
  [authMiddleware],
  errorHandler(orderController.createOrder.bind(orderController))
);

export default orderRoutes;
