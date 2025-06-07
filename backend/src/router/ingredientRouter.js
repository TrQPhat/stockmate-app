const express = require("express");
const router = express.Router();

const ingredientController = require("../app/api/ingredientController.js");

router.get(
  "/products/ingredients/:id",
  ingredientController.getIngredientsByProduct
); // Lấy danh sách nguyên liệu của sản phẩm
router.post("/ingredients/create", ingredientController.createIngredient); // Thêm nguyên liệu
router.post("/ingredients/update", ingredientController.updateIngredient); // Cập nhật nguyên liệu
router.post("/ingredients/delete", ingredientController.deleteIngredient); // Xóa nguyên liệu

module.exports = router;
