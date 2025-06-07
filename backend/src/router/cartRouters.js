const express = require("express");
const router = express.Router();

const cartController = require("../app/api/cartController.js");
const authToken = require("../middleware/authToken.js");

router.get("/:user_id", authToken, cartController.getCart); //Lấy danh sách giỏ hàng của một user
router.post("/add/", authToken, cartController.addToCart); //Thêm sản phẩm vào giỏ hàng
router.put("/", authToken, cartController.updateCart); //Cập nhật số lượng sản phẩm trong giỏ hàng
router.delete("/:cart_id", authToken, cartController.removeFromCart); //Xóa sản phẩm khỏi giỏ hàng
router.delete("/clear/:user_id", authToken, cartController.clearCart); //Xóa toàn bộ sản phẩm trong giỏ hàng
router.get("/count/:user_id", authToken, cartController.getTotalItems); //Đếm số lượng sản phẩm trong giỏ hàng

module.exports = router;
