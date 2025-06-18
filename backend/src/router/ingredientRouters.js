const express = require("express");
const router = express.Router();
const ingredientController = require("../app/api/ingredientController");
const authToken = require("../middleware/authToken");


router.get("/", authToken, ingredientController.getAllProducts);
router.post("/", authToken, ingredientController.createProduct);
router.get("/:id", authToken, ingredientController.getProductById);
router.put("/:id", authToken, ingredientController.updateProduct);
router.delete("/:id", authToken, ingredientController.deleteProduct);

module.exports = router;
