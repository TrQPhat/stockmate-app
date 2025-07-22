const express = require("express");
const router = express.Router();
const homeController = require("../app/api/homeController");
const authToken = require("../middleware/authToken");

router.get("/stats/:storage_id", authToken, homeController.getHomeStats);

module.exports = router;
