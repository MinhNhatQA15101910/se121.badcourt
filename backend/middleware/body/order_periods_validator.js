// Validate order periods
const orderPeriodsValidator = (req, res, next) => {
  console.log("Order periods validator middleware:");

  try {
    const orderPeriods = req.body.order_periods;

    if (!orderPeriods) {
      return res.status(400).json({ msg: "Order periods are required." });
    }

    if (orderPeriods.length === 0) {
      return res.status(400).json({ msg: "Order periods cannot be empty." });
    }

    for (let i = 0; i < orderPeriods.length; i++) {
      const startTime = orderPeriods[i].hour_from;
      const endTime = orderPeriods[i].hour_to;
      if (startTime >= endTime) {
        return res.status(400).json({ msg: "Invalid order periods" });
      }
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default orderPeriodsValidator;
