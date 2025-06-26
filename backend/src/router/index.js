const express = require("express");
const router = express.Router();

// Import route modules
const userRouter = require("./userRouters");
const fcmTokenRouter = require("./fcmTokenRouters");
const storageRouter = require("./storageRouters");
const groceryRouter = require("./groceryRouters"); // groceries
//const ingredientRouter = require("./ingredientRouters"); // ingredients nit
const positionRouter = require("./positionRouters");
const categoryRouter = require("./categoryRouters");
const dishRouter = require("./dishRouters"); // recipes/dishes
//const noteRouter = require("./noteRouters"); //not yet
//const favoriteRouter = require("./favoriteRouters"); // not yet
//const reminderRouter = require("./reminderRouters"); //not yet
const shoppingListRouter = require("./shoppingRouters");
//const notificationRouter = require("./notificationRouters"); //not yet

// Mount routes
router.use("/users", userRouter);
router.use("/fcm-tokens", fcmTokenRouter);
router.use("/storages", storageRouter);
router.use("/groceries", groceryRouter);
//router.use("/ingredients", ingredientRouter);
router.use("/positions", positionRouter);
router.use("/categories", categoryRouter);
router.use("/dishes", dishRouter);
//router.use("/notes", noteRouter);
//router.use("/favorites", favoriteRouter);
//router.use("/reminders", reminderRouter);
router.use("/shopping", shoppingListRouter);
//router.use("/notifications", notificationRouter);

module.exports = router;
