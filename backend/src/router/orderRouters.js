const express = require("express");
const router = express.Router();

const orderController = require("../app/api/orderController.js");
const authToken = require("../middleware/authToken.js");

router.post("/create/", authToken, orderController.createOrder);

router.post("/pay/:id", authToken, orderController.updatePaymentStatus);

router.get(
  "/get/process/:user_id",
  authToken,
  orderController.getOrdersInProcess
);
router.get(
  "/get/history/:user_id",
  authToken,
  orderController.getOrdersHistory
);

router.post("/deliver/:id", authToken, orderController.updateDeliveryStatus);

router.post("/delete/:id", authToken, orderController.deleteOrder);

router.post("/cancel/:id", authToken, orderController.cancelOrder);

module.exports = router;
