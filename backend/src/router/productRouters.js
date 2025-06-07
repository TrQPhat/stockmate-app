const express = require("express");
const upload = require("../config/multer/index.js");
const router = express.Router();

const productController = require("../app/api/productController.js");
const authToken = require("../middleware/authToken.js");

router.get("/getall/:page/:limit/", productController.getAllProducts);
router.get(
  "/getallavailable/:page/:limit/",
  productController.getAllProductsAvailable
);
router.get("/best-seller/", productController.getTopStockProducts);
router.get("/getproduct/:id", productController.getProductById);
router.get("/search", productController.searchProducts);
router.post(
  "/create",
  authToken,
  upload.single("image"),
  productController.createProduct
);
router.post(
  "/update/:id/",
  authToken,
  upload.single("image"),
  productController.updateProduct
);
router.post("/delete/:id/", authToken, productController.deleteProduct);

module.exports = router;
