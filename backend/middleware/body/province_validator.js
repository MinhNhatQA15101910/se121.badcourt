// Validate province
const provinceValidator = (req, res, next) => {
  console.log("Province validator middleware:");
  console.log("- Province: " + req.body.province);

  try {
    const province = req.body.province;

    if (!province) {
      return res.status(400).json({ msg: "Province is required." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default provinceValidator;
