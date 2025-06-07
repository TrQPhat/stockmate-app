const express = require("express");
const router = express.Router();
const storageController = require("../app/api/storageController");
const authToken = require("../middleware/authToken");

router.get("/", authToken, storageController.getAllStorages);
router.post("/", authToken, storageController.createStorage);
router.get("/:id", authToken, storageController.getStorageById);
router.put("/:id", authToken, storageController.updateStorage);
router.delete("/:id", authToken, storageController.deleteStorage);

module.exports = router;
