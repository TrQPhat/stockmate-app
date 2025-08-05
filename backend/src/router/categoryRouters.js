const express = require("express");
const router = express.Router();
const categoryController = require("../app/api/categoryController");
const authToken = require("../middleware/authToken");

// Tất cả các route này đều được bảo vệ bằng authToken middleware
router.use(authToken);

// Lấy danh sách tất cả danh mục
router.get("/:storage_id", categoryController.getAllCategories);

// Lấy danh mục theo id
router.get("/:id", categoryController.getCategoryById);

// Tạo mới danh mục
router.post("/", categoryController.createCategory);

// Cập nhật danh mục theo id
router.put("/:id", categoryController.updateCategory);

// Xóa danh mục theo id
router.delete("/:id", categoryController.deleteCategory);

module.exports = router;
