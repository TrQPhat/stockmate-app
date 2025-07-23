const express = require("express");
const router = express.Router();
const groceryController = require("../app/api/groceryController");
const authToken = require("../middleware/authToken");

router.get("/", authToken, groceryController.getAllGroceries);
router.get("/expiring", authToken, groceryController.getExpiringGroceries);
router.post("/", authToken, groceryController.createGrocery);
router.get("/:id", authToken, groceryController.getGroceryById);
router.put("/:id", authToken, groceryController.updateGrocery);
router.delete("/multiple", authToken, groceryController.deleteMultipleGroceries);
router.delete("/:id", authToken, groceryController.deleteGrocery);

module.exports = router;
