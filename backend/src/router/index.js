const express = require("express");
const router = express.Router();

// Import route modules
const userRouter = require("./userRouters");
const fcmTokenRouter = require("./fcmTokenRouters");
const storageRouter = require("./storageRouters");
const groceryRouter = require("./groceryRouters"); // groceries
const positionRouter = require("./positionRouters");
const categoryRouter = require("./categoryRouters");
const dishRouter = require("./dishRouters"); // recipes/dishes
const shoppingListRouter = require("./shoppingRouters");
const homeRouter = require("./homeRouters"); // Home statistics
const statsRouter = require("./statsRouters"); // Waste statistics

// Mount routes
router.use("/users", userRouter);
router.use("/fcm-tokens", fcmTokenRouter);
router.use("/storages", storageRouter);
router.use("/groceries", groceryRouter);
router.use("/positions", positionRouter);
router.use("/categories", categoryRouter);
router.use("/dishes", dishRouter);
router.use("/shopping", shoppingListRouter);
router.use("/home", homeRouter); 
router.use("/stats", statsRouter); 

module.exports = router;
