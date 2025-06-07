const express = require("express");
const router = express.Router();

const categoryController = require("../app/api/categoryController.js");
const authToken = require("../middleware/authToken.js");

router.get("/", authToken, categoryController.getAll);
router.post("/add/", authToken, categoryController.addCategory);
router.post("/update/", authToken, categoryController.updateCategory);
router.post("/delete/", authToken, categoryController.deleteCategory);

module.exports = router;
