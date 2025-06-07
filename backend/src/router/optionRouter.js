const express = require("express");
const router = express.Router();
const optionController = require("../app/api/optionController.js");

// Lấy danh sách tất cả các option
router.get("/", optionController.getAllOptions);

// Lấy chi tiết một option theo ID
router.get("/:product_id", optionController.getOptionsByProductId);

// Tạo một option mới
router.post("/", optionController.createOption);

// Cập nhật một option theo ID
router.put("/:id", optionController.updateOption);

// Xóa một option theo ID
router.delete("/:id", optionController.deleteOption);

module.exports = router;
