const express = require("express");
const router = express.Router();
const dishController = require("../app/api/dishController");
const authToken = require("../middleware/authToken");

router.use(authToken);

router.get("/:storage_id", dishController.getAllDishes);
router.get("/:id", dishController.getDishById);
router.post("/", dishController.createDish);
router.put("/:id", dishController.updateDish);
router.delete("/:id", dishController.deleteDish);

module.exports = router;
