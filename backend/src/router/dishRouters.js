const express = require("express");
const router = express.Router();
const dishController = require("../app/api/dishController");
const authToken = require("../middleware/authToken");

// Tất cả route đều yêu cầu xác thực
// router.use(authToken);

// // Route cho tính năng gợi ý món ăn dựa trên nguyên liệu có sẵn
// router.get("/suggestions/cookable", dishController.suggestDish); // Lấy danh sách món ăn có thể nấu dựa trên nguyên liệu có sẵn

// // Routes cho Dishes
// router.get("/", dishController.getAllDish); // Lấy tất cả các món ăn
// router.post("/", dishController.createDish); // Tạo mới món ăn
// router.get("/:dishId", dishController.getDishById); // Lấy món ăn theo ID
// router.put("/:dishId", dishController.updateDish); // Cập nhật món ăn theo ID
// router.delete("/:dishId", dishController.deleteDish); // Xóa món ăn theo ID

// // Routes cho Dish Ingredients
// router.post("/:dishId/ingredients", dishController.addIngredient); // Thêm nguyên liệu vào công thức món ăn
// router.put(
//   "/:dishId/ingredients/:ingredientId",
//   dishController.updateIngredient
// ); // Cập nhật nguyên liệu của công thức món ăn
// router.delete(
//   "/:dishId/ingredients/:ingredientId",
//   dishController.removeIngredient
// ); // Xóa nguyên liệu khỏi công thức món ăn

module.exports = router;
