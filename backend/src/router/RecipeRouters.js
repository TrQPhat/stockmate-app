const express = require("express");
const router = express.Router();
const recipeController = require("../app/api/recipeController");
const authToken = require("../middleware/authToken");

// Tất cả route đều yêu cầu xác thực
router.use(authToken);

// Route cho tính năng gợi ý món ăn dựa trên nguyên liệu có sẵn
router.get("/suggestions/cookable", recipeController.suggestRecipe); // Lấy danh sách món ăn có thể nấu dựa trên nguyên liệu có sẵn

// Routes cho Recipees
router.get("/", recipeController.getAllRecipe); // Lấy tất cả các món ăn
router.post("/", recipeController.createRecipe); // Tạo mới món ăn
router.get("/:dishId", recipeController.getRecipeById); // Lấy món ăn theo ID
router.put("/:dishId", recipeController.updateRecipe);// Cập nhật món ăn theo ID
router.delete("/:dishId", recipeController.deleteRecipe); // Xóa món ăn theo ID

// Routes cho Recipe Ingredients
router.post("/:dishId/ingredients", recipeController.addIngredient); // Thêm nguyên liệu vào công thức món ăn
router.put("/:dishId/ingredients/:ingredientId", recipeController.updateIngredient); // Cập nhật nguyên liệu của công thức món ăn
router.delete("/:dishId/ingredients/:ingredientId", recipeController.removeIngredient); // Xóa nguyên liệu khỏi công thức món ăn

module.exports = router;