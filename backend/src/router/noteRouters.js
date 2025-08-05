// routes/noteRoutes.js
const express = require("express");
const router = express.Router();
const noteController = require("../app/api/noteController");

const authToken = require("../middleware/authToken");

router.use(authToken);

router.get("/:dish_id", noteController.getAll);
router.post("/", noteController.create);
router.put("/:id", noteController.update);
router.delete("/:id", noteController.delete);

module.exports = router;