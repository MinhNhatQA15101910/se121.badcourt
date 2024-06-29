// Validate price per hour
const pricePerHourValidator = (req, res, next) => {
  console.log("Price per hour validator middleware:");
  console.log("- Price per hour: " + req.body.price);

  try {
    const pricePerHour = req.body.price_per_hour;

    if (!pricePerHour) {
      return res.status(400).json({ msg: "Price is required." });
    }

    if (Number(pricePerHour) <= 0) {
      return res.status(400).json({ msg: "Invalid price" });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default pricePerHourValidator;
