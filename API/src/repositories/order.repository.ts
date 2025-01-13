import { injectable } from "inversify";
import { IOrderRepository } from "../interfaces/repositories/IOrder.repository";
import { NewOrderDto } from "../dtos/orders/newOrder.dto";
import Order from "../models/order";

@injectable()
export class OrderRepository implements IOrderRepository {
  async createOrder(newOrderDto: NewOrderDto): Promise<any> {
    let order = new Order(newOrderDto);
    order = await order.save();
    return order;
  }
}
