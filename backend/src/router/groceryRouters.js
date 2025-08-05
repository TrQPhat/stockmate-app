const express = require("express");
const router = express.Router();
const groceryController = require("../app/api/groceryController");
const upload = require("../config/multer/index.js");
const authToken = require("../middleware/authToken");

router.get("/:storage_id", authToken, groceryController.getAllGroceries);
router.get("/expiring/:storage_id", authToken, groceryController.getExpiringGroceries);
router.get("/expired/:storage_id", authToken, groceryController.getExpiredGroceries);
router.post("/", authToken, upload.single("image"), groceryController.createGrocery);
//router.get("/:id", authToken, groceryController.getGroceryById);
router.put("/:id", authToken, upload.single("image"), groceryController.updateGrocery);
router.delete("/multiple", authToken, groceryController.deleteMultipleGroceries);
router.delete("/:id", authToken, groceryController.deleteGrocery);
router.post("/scan-expiring", groceryController.scanAndNotifyExpiringGroceries);

module.exports = router;
