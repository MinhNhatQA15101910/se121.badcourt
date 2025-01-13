import mongoose from "mongoose";
import { AppOrderSchema } from "../schemas/orders/appOrder.schema";

const Order = mongoose.model("Order", AppOrderSchema);

export default Order;
