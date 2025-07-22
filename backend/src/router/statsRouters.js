const express = require("express");
const router = express.Router();
const statsController = require("../app/api/statsController");
const authToken = require("../middleware/authToken");

router.get("/waste/:storage_id", authToken, statsController.getWasteStats);


module.exports = router;