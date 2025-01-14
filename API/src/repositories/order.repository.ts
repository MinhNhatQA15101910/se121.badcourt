import { injectable } from "inversify";
import { IOrderRepository } from "../interfaces/repositories/IOrder.repository";
import { NewOrderDto } from "../dtos/orders/newOrder.dto";
import Order from "../models/order";
import { PagedList } from "../helper/pagedList";
import { OrderParams } from "../params/order.params";
import { Aggregate } from "mongoose";

@injectable()
export class OrderRepository implements IOrderRepository {
  async createOrder(newOrderDto: NewOrderDto): Promise<any> {
    let order = new Order(newOrderDto);
    order = await order.save();
    return order;
  }

  async getOrderById(orderId: string): Promise<any> {
    return await Order.findById(orderId);
  }

  async getOrders(orderParams: OrderParams): Promise<PagedList<any>> {
    let aggregate: Aggregate<any[]> = Order.aggregate([]);

    if (orderParams.userId) {
      aggregate = aggregate.match({ userId: orderParams.userId });
    }

    if (orderParams.courtId) {
      aggregate = aggregate.match({ courtId: orderParams.courtId });
    }

    if (orderParams.state) {
      aggregate = aggregate.match({ state: orderParams.state });
    }

    switch (orderParams.sortBy) {
      case "price":
        aggregate = aggregate.sort({
          price: orderParams.order === "asc" ? 1 : -1,
        });
        break;
      case "createdAt":
      default:
        aggregate = aggregate.sort({
          createdAt: orderParams.order === "asc" ? 1 : -1,
        });
    }

    const pipeline = aggregate.pipeline();
    let countAggregate = Order.aggregate([...pipeline, { $count: "count" }]);

    return await PagedList.create<any>(
      aggregate,
      countAggregate,
      orderParams.pageNumber,
      orderParams.pageSize
    );
  }
}
