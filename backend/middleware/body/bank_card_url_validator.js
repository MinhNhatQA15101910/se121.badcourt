// Validate bank card image url
const bankCardUrlValidator = (req, res, next) => {
  console.log("Bank card image url validator middleware:");
  console.log("- Front url: " + req.body.bank_card_url_front);
  console.log("- Back url: " + req.body.bank_card_url_back);

  try {
    const { bank_card_url_front, bank_card_url_back } = req.body;

    if (!bank_card_url_front || !bank_card_url_back) {
      return res.status(400).json({ msg: "Bank card image url is required." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default bankCardUrlValidator;
