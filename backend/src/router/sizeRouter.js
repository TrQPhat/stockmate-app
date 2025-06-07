const express = require("express");
const router = express.Router();

const sizeController = require("../app/api/sizeController.js");
const authToken = require("../middleware/authToken.js");

router.get("/getall", authToken, sizeController.getAllSize);

module.exports = router;
