const express = require("express");
const router = express.Router();
const productController = require("../app/api/productController");
const authToken = require("../middleware/authToken");

router.get("/", authToken, productController.getAllProducts);
router.post("/", authToken, productController.createProduct);
router.get("/:id", authToken, productController.getProductById);
router.put("/:id", authToken, productController.updateProduct);
router.delete("/:id", authToken, productController.deleteProduct);

module.exports = router;
