const express = require("express");
const router = express.Router();
const dishController = require("../app/api/dishController");
const upload = require("../config/multer/index.js");
const authToken = require("../middleware/authToken");

router.use(authToken);

router.get("/:storage_id/:user_id", dishController.getAllDishes);
router.get("/:id", dishController.getDishById);
router.post("/", upload.single("image"), dishController.createDish);
router.put("/:id", upload.single("image"), dishController.updateDish);
router.delete("/:id", dishController.deleteDish);
router.post("/favorite", dishController.toggleFavoriteDish);

module.exports = router;



