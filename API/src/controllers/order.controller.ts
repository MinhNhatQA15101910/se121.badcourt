import { Request, Response } from "express";
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
import { PORT } from "../secrets";
import { UnauthorizedException } from "../exceptions/unauthorized.exception";
import { OrderParams } from "../params/order.params";
import { OrderParamsSchema } from "../schemas/orders/orderParams.schema";
import { addPaginationHeader } from "../helper/helpers";

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

  async getOrder(req: Request, res: Response) {
    const orderId = req.params.id;

    const order = await this._orderRepository.getOrderById(orderId);
    if (!order) {
      throw new NotFoundException("Order not found!");
    }

    const user = req.user;
    if (!(user.role === "admin") && order.userId !== user._id.toString()) {
      throw new UnauthorizedException("Unauthorized to access this order!");
    }

    res.json(OrderDto.mapFrom(order));
  }

  async getOrders(req: Request, res: Response) {
    const orderParams: OrderParams = OrderParamsSchema.parse(req.query);

    const orders = await this._orderRepository.getOrders(orderParams);

    addPaginationHeader(res, orders);

    const orderDtos: OrderDto[] = [];
    for (let post of posts) {
      const postDto = PostDto.mapFrom(post);

      // Add user info to postDto
      const user = await this._userRepository.getUserById(post.userId);
      postDto.publisherUsername = user.username;
      postDto.publisherImageUrl =
        user.image === undefined ? "" : user.image.url;

      // Add comments to postDto
      const comments = await this._commentRepository.getTop3CommentsForPost(
        post._id
      );
      for (let comment of comments) {
        const commentDto = CommentDto.mapFrom(comment);

        const user = await this._userRepository.getUserById(comment.userId);
        commentDto.publisherUsername = user.username;
        commentDto.publisherImageUrl =
          user.image === undefined ? "" : user.image.url;

        postDto.comments.push(commentDto);
      }
      postDto.commentsCount = await this._commentRepository.getCommentsCount(
        post._id
      );

      // Add liked users to postDto
      for (let userId of post.likedUsers) {
        const user = await this._userRepository.getUserById(userId);
        const userDto = UserDto.mapFrom(user);
        postDto.likedUsers.push(userDto);
      }

      postDtos.push(postDto);
    }

    res.json(postDtos);
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

    res
      .status(201)
      .location(`https://localhost:${PORT}/api/orders/${order._id})}`)
      .json(OrderDto.mapFrom(order));
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
