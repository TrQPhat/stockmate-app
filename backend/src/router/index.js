const express = require("express");
const router = express.Router();

const userRouter = require("./userRouters");
const ingredientRouter = require("./ingredientRouters");
const fcmTokenRouter = require("./fcmTokenRouters");
const storageRouter = require("./storageRouters");
const storageMemberRouter = require("./storageMemberRouters");
const ingredientLogRouter = require("./ingredientLogRouters");
const categoryRouter = require("./categoryRouters");
const shoppingListRouter = require("./shoppingListRouters");
const RecipeRouters = require("./RecipeRouters");

router.use("/users", userRouter);
router.use("/ingredients", ingredientRouter);
router.use("/categories", categoryRouter);
router.use("/fcm-tokens", fcmTokenRouter);
router.use("/storages", storageRouter);
router.use("/storage-members", storageMemberRouter);
router.use("/ingredient-logs", ingredientLogRouter);
router.use("/shopping-lists", shoppingListRouter);
router.use("/recipes", RecipeRouters);

module.exports = router;
