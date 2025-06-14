const express = require("express");
const router = express.Router();
const cookingHistoryController = require("../app/api/cookingHistoryController");
const authToken = require("../middleware/authToken");

// Tất cả các route đều yêu cầu xác thực
router.use(authToken);

// Lấy lịch sử nấu ăn của người dùng
router.get("/", cookingHistoryController.getUserCookingHistory); // lấy lịch sử nấu ăn của người dùng

// Ghi lại một món ăn đã nấu
router.post("/", cookingHistoryController.logCookedDish); // ghi lại món ăn đã nấu

module.exports = router;