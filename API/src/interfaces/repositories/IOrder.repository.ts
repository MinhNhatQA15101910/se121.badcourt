import { NewOrderDto } from "../../dtos/orders/newOrder.dto";
import { PagedList } from "../../helper/pagedList";
import { OrderParams } from "../../params/order.params";

export interface IOrderRepository {
  createOrder(newOrderDto: NewOrderDto): Promise<any>;
  getOrderById(orderId: string): Promise<any>;
  getOrders(orderParams: OrderParams): Promise<PagedList<any>>;
}
