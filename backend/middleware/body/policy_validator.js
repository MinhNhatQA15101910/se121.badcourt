// Validate policy
const policyValidator = (req, res, next) => {
  console.log("Policy validator middleware:");
  console.log("- Policy: " + req.body.policy);

  try {
    const policy = req.body.policy;

    if (!policy) {
      return res.status(400).json({ msg: "Policy is required." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default policyValidator;
