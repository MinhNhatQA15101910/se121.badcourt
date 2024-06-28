// Validate pincode
const pincodeValidator = (req, res, next) => {
  console.log("Pincode validator middleware:");
  console.log("- Pincode: " + req.body.pincode);

  try {
    const pincode = req.body.pincode;

    if (!pincode) {
      return res.status(400).json({ msg: "Pincode is required." });
    }

    let isValid = pincode.length === 6 && Number(pincode);

    if (!isValid) {
      return res.status(400).json({ msg: "Pincode must be 6 digits string." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default pincodeValidator;
