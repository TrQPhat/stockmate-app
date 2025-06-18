const express = require("express");
const router = express.Router();
const productLogController = require("../app/api/ingredientLogController");
const authToken = require("../middleware/authToken");

// Lấy tất cả product logs
router.get("/", authToken, productLogController.getAllProductLogs);

// Lấy product log theo id
router.get("/:id", authToken, productLogController.getProductLogById);

// Tạo mới product log
router.post("/", authToken, productLogController.createProductLog);

// Cập nhật product log theo id
router.put("/:id", authToken, productLogController.updateProductLog);

// Xóa product log theo id
router.delete("/:id", authToken, productLogController.deleteProductLog);

module.exports = router;
