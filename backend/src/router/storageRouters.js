const express = require("express");
const router = express.Router();
const storageController = require("../app/api/storageController");
const authToken = require("../middleware/authToken");

router.get("/", authToken, storageController.getAllStorages);
router.get("/member/:storage_id", authToken, storageController.getAllUsersInStorage);
router.post("/create", authToken, storageController.createStorage);
router.post("/join/key", authToken, storageController.joinToStorageByKey);
router.get("/:id", authToken, storageController.getStorageById);
router.put("/:id", authToken, storageController.updateStorage);
router.delete("/:id", authToken, storageController.deleteStorage);

module.exports = router;
