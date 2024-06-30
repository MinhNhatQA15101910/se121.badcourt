// Packages
import express from "express";

// Models
import Order from "../../models/order.js";

// Header middleware
import playerValidator from "../../middleware/header/player_validator.js";
import orderIdValidator from "../../middleware/params/order_id_validator.js";

const playerOrderRouter = express.Router();

// Get all orders route
playerOrderRouter.get("/player/orders", playerValidator, async (req, res) => {
  try {
    const { user_id } = req.query;

    const orders = await Order.find({ user_id });

    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get order by id route
playerOrderRouter.get(
  "/player/orders/:order_id",
  playerValidator,
  orderIdValidator,
  async (req, res) => {
    try {
      const { order_id } = req.params;

      const order = await Order.findById(order_id);

      res.json(order);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

export default playerOrderRouter;
