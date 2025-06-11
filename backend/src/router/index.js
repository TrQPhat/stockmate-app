const express = require("express");
const router = express.Router();

const userRouter = require("./userRouters");
const productRouter = require("./productRouters");
const fcmTokenRouter = require("./fcmTokenRouters");
const storageRouter = require("./storageRouters");
const storageMemberRouter = require("./storageMemberRouters");
const productLogRouter = require("./productLogRouters");
const categoryRouter = require("./categoryRouters");
const shoppingListRouter = require("./shoppingListRouters");
const dishRouter = require("./dishRouters");

router.use("/users", userRouter);
router.use("/products", productRouter);
router.use("/categories", categoryRouter);
router.use("/fcm-tokens", fcmTokenRouter);
router.use("/storages", storageRouter);
router.use("/storage-members", storageMemberRouter);
router.use("/product-logs", productLogRouter);
router.use("/shopping-lists", shoppingListRouter);
router.use("/dishes", dishRouter);

module.exports = router;
