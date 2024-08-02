// Validate detail address
const detailAddressValidator = (req, res, next) => {
  console.log("Detail address validator middleware:");
  console.log("- Detail address: " + req.body.detail_address);

  try {
    const detailAddress = req.body.detail_address;

    if (!detailAddress) {
      return res.status(400).json({ msg: "Detail address is required." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default detailAddressValidator;
