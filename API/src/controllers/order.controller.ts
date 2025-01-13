import { inject, injectable } from "inversify";
import { IOrderRepository } from "../interfaces/repositories/IOrder.repository";
import { INTERFACE_TYPE } from "../utils/appConsts";
import { NewOrderDto } from "../dtos/orders/newOrder.dto";
import { CreateOrderSchema } from "../schemas/orders/createOrder.schema";
import { ICourtRepository } from "../interfaces/repositories/ICourt.repository";
import { NotFoundException } from "../exceptions/notFound.exception";
import { IFacilityRepository } from "../interfaces/repositories/IFacility.repository";
import { BadRequestException } from "../exceptions/badRequest.exception";
import { OrderDto } from "../dtos/orders/order.dto";

const dayInWeekMap = [
  "sunday",
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
  "saturday",
];

@injectable()
export class OrderController {
  private _courtRepository: ICourtRepository;
  private _facilityRepository: IFacilityRepository;
  private _orderRepository: IOrderRepository;

  constructor(
    @inject(INTERFACE_TYPE.CourtRepository) courtRepository: ICourtRepository,
    @inject(INTERFACE_TYPE.FacilityRepository)
    facilityRepository: IFacilityRepository,
    @inject(INTERFACE_TYPE.OrderRepository)
    orderRepository: IOrderRepository
  ) {
    this._courtRepository = courtRepository;
    this._facilityRepository = facilityRepository;
    this._orderRepository = orderRepository;
  }

  async createOrder(req: Request, res: Response) {
    const newOrderDto: NewOrderDto = CreateOrderSchema.parse(req.body);

    // Attach userId to newOrderDto
    const user = req.user;
    newOrderDto.userId = user._id.toString();

    // Check if court exists
    const courtId = newOrderDto.courtId;
    const court = await this._courtRepository.getCourtById(courtId);
    if (!court) {
      throw new NotFoundException("Court not found!");
    }

    // Check if facility active is in the time period
    const facility = await this._facilityRepository.getFacilityById(
      court.facilityId
    );
    if (!facility) {
      throw new NotFoundException("Facility not found!");
    }

    const orderDayInWeek = new Date(newOrderDto.timePeriod?.hourFrom!).getDay();
    const active = facility.activeAt[dayInWeekMap[orderDayInWeek]];
    if (!active) {
      throw new BadRequestException("Facility is not active at this time!");
    }

    // Check if the period is within the active time
    const activeHourFrom = new Date(active.hourFrom).getHours();
    const activeHourTo = new Date(active.hourTo).getHours();
    const orderHourFrom = new Date(
      newOrderDto.timePeriod?.hourFrom!
    ).getHours();
    const orderHourTo = new Date(newOrderDto.timePeriod?.hourTo!).getHours();
    console.log(activeHourFrom, activeHourTo, orderHourFrom, orderHourTo);
    if (
      !this.isOverlap(
        { hourFrom: activeHourFrom, hourTo: activeHourTo },
        { hourFrom: orderHourFrom, hourTo: orderHourTo }
      )
    ) {
      throw new BadRequestException("Period is not within the active time!");
    }

    // Check if the period is intersect with other orders
    for (let orderPeriod of court.orderPeriods) {
      if (this.isIntersect(orderPeriod, newOrderDto.timePeriod!)) {
        throw new BadRequestException("Period is intersect with other orders!");
      }
    }

    // Check if the period is intersect with inactive time
    for (let inactive of court.inactivePeriods) {
      if (this.isIntersect(inactive, newOrderDto.timePeriod!)) {
        throw new BadRequestException(
          "Period is intersect with inactive time!"
        );
      }
    }

    newOrderDto.address = facility.detailAddress;
    newOrderDto.facilityName = facility.facilityName;
    newOrderDto.price = court.pricePerHour * (orderHourTo - orderHourFrom);
    newOrderDto.image = facility.facilityImages.find(
      (image: any) => image.isMain
    );

    const order = await this._orderRepository.createOrder(newOrderDto);

    // Update court orderPeriods
    court.orderPeriods.push(newOrderDto.timePeriod!);
    court.updatedAt = new Date();
    await court.save();

    const orderDto = OrderDto.mapFrom(order);

    res.json(orderDto);
  }

  isIntersect(timePeriod1: any, timePeriod2: any) {
    return (
      timePeriod1.hourFrom < timePeriod2.hourTo &&
      timePeriod1.hourTo > timePeriod2.hourFrom
    );
  }

  isOverlap(outsideTimePeriod1: any, insideTimePeriod2: any) {
    return (
      outsideTimePeriod1.hourFrom <= insideTimePeriod2.hourFrom &&
      outsideTimePeriod1.hourTo >= insideTimePeriod2.hourTo
    );
  }
}
