const express = require("express");
const router = express.Router();
const shoppingController = require("../app/api/shoppingController");
const authToken = require("../middleware/authToken");

// Tất cả route đều yêu cầu xác thực
router.use(authToken);

// --- Routes cho Shopping Lists ---
router.get("/", shoppingController.getAllLists);
router.post("/", shoppingController.createList);
router.get("/:listId", shoppingController.getListById);
router.put("/:listId", shoppingController.updateList);
router.delete("/:listId", shoppingController.deleteList);

// --- Routes cho Shopping List Items ---
router.post("/:listId/items", shoppingController.addItemToList);
router.put("/:listId/items/:itemId", shoppingController.updateItemInList);
router.delete("/:listId/items/:itemId", shoppingController.deleteItemFromList);

module.exports = router;