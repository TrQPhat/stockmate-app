const express = require("express");
const router = express.Router();

const addressController = require("../app/api/addressController.js");
const authToken = require("../middleware/authToken.js");

// Lấy danh sách địa chỉ của người dùng
router.get("/user/:user_id", authToken, addressController.getUserAddresses);

// Thêm địa chỉ mới
router.post("/", authToken, addressController.addAddress);

// Cập nhật địa chỉ
router.put("/update/:id", authToken, addressController.updateAddress);

// Xóa địa chỉ
router.delete("/delete/:id", authToken, addressController.deleteAddress);

module.exports = router;
