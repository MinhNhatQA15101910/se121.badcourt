import { NewOrderDto } from "../../dtos/orders/newOrder.dto";

export interface IOrderRepository {
  createOrder(newOrderDto: NewOrderDto): Promise<any>;
}
