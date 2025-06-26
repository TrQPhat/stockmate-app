const express = require("express");
const router = express.Router();
const shoppingController = require("../app/api/shoppingController");
const authToken = require("../middleware/authToken");

// Tất cả route đều yêu cầu xác thực
router.use(authToken);

// --- Routes cho Danh sách mua sắm (Shopping Lists) ---
router.get("/:storageId", shoppingController.getAllShoppingLists);
router.post("/", shoppingController.createList);
router.put("/:listId", shoppingController.updateList);
router.delete("/:listId", shoppingController.deleteList);
router.post("/complete/:listId", shoppingController.completeShoppingList);

// --- Routes cho Các mặt hàng trong danh sách (Shopping List Items) ---
router.get("/detail/:listId", shoppingController.getListById);
router.post("/items/", shoppingController.addItemToList);
router.put("/items/:itemId", shoppingController.updateItemInList);
router.patch("/items/:itemId", shoppingController.toggleItemPurchasedStatus);
router.delete("/items/:itemId", shoppingController.deleteItemFromList);

module.exports = router;
