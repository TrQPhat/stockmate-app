const express = require("express");
const router = express.Router();
const fcmTokenController = require("../app/api/fcmTokenController");
const authToken = require("../middleware/authToken");

// Lấy danh sách tất cả FcmToken
router.get("/", authToken, fcmTokenController.getAll);

// Lấy FcmToken theo id
router.get("/:id", authToken, fcmTokenController.getById);

// Tạo mới FcmToken
router.post("/", authToken, fcmTokenController.create);

// Cập nhật FcmToken theo id
router.put("/:id", authToken, fcmTokenController.update);

// Xóa FcmToken theo id
router.delete("/:id", authToken, fcmTokenController.delete);

module.exports = router;
