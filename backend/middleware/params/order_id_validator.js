import Order from "../../models/order.js";

const orderIdValidator = async (req, res, next) => {
  console.log("Order id validator middleware:");
  console.log("- Order id: " + req.params.order_id);

  try {
    const orderId = req.params.order_id;

    if (!orderId) {
      return res.status(400).json({ msg: "Order id is required." });
    }

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(400).json({ msg: "Order not exist." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default orderIdValidator;
