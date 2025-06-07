const express = require("express");
const router = express.Router();

const userRouter = require("./userRouters");
const productRouter = require("./productRouters");
const fcmTokenRouter = require("./fcmTokenRouters");
const storageRouter = require("./storageRouters");
const storageMemberRouter = require("./storageMemberRouters");
const productLogRouter = require("./productLogRouters");

router.use("/users", userRouter);
router.use("/products", productRouter);
router.use("/fcm-tokens", fcmTokenRouter);
router.use("/storages", storageRouter);
router.use("/storage-members", storageMemberRouter);
router.use("/product-logs", productLogRouter);

module.exports = router;
