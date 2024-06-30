// Validate price range
const priceRangeValidator = (req, res, next) => {
  console.log("Price range validator middleware:");
  console.log(`- Min price: ${req.query.min_price}`);
  console.log(`- Max price: ${req.query.max_price}`);

  try {
    let { min_price, max_price } = req.query;

    if (min_price) {
      console.log("Validate min price");
      if (isNaN(Number(min_price)) || Number(min_price) < 0) {
        return res.status(400).json({ msg: "Invalid price range." });
      }
    } else {
      req.query.min_price = 0;
      min_price = 0;
    }

    if (max_price) {
      console.log("Validate max price");
      if (isNaN(Number(min_price)) || max_price < 0) {
        return res.status(400).json({ msg: "Invalid price range." });
      }
    } else {
      req.query.max_price = Infinity;
      max_price = Infinity;
    }

    if (min_price >= max_price) {
      return res.status(400).json({ msg: "Invalid price range." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default priceRangeValidator;
