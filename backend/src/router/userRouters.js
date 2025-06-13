const express = require("express");
const router = express.Router();
const userController = require("../app/api/userController");
const authToken = require("../middleware/authToken");

router.get("/", authToken, userController.getAll);
router.get("/:id", authToken, userController.getById);
router.post("/login", userController.login);
router.post("/logout", userController.logout);
router.post("/refreshToken", userController.refreshToken);
router.post("/register", userController.register);
router.put("/:id", authToken, userController.update);
router.delete("/:id", authToken, userController.delete);

module.exports = router;
