const express = require("express");
const router = express.Router();
const groceryController = require("../app/api/groceryController");
const upload = require("../config/multer/index.js");
const authToken = require("../middleware/authToken");

router.get("/", authToken, groceryController.getAllGroceries);
router.get("/expiring", authToken, groceryController.getExpiringGroceries);
router.get("/expired", authToken, groceryController.getExpiredGroceries);
router.post("/", authToken, upload.single("image"), groceryController.createGrocery);
router.get("/:id", authToken, groceryController.getGroceryById);
router.put("/:id", authToken, upload.single("image"), groceryController.updateGrocery);
router.delete("/multiple", authToken, groceryController.deleteMultipleGroceries);
router.delete("/:id", authToken, groceryController.deleteGrocery);

module.exports = router;
