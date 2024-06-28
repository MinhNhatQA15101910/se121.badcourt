import { isValidPhoneNumber } from "libphonenumber-js";

// Validate phone number
const phoneNumberValidator = (req, res, next) => {
  console.log("Phone number validator middleware:");
  console.log("- Phone number: " + req.body.phone_number);

  try {
    const phoneNumber = req.body.phone_number;

    if (!phoneNumber) {
      return res.status(400).json({ msg: "Phone number is required." });
    }

    if (!isValidPhoneNumber(phoneNumber, "VN")) {
      return res.status(400).json({ msg: "Invalid phone number." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default phoneNumberValidator;
