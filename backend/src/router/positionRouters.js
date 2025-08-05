const express = require("express");
const router = express.Router();
const positionController = require("../app/api/positionController");
const authToken = require("../middleware/authToken");

// Tất cả các route này đều được bảo vệ bằng authToken middleware
router.use(authToken);

// Lấy danh sách tất cả vị trí
router.get("/:storage_id", positionController.getAll);

// Lấy vị trí theo id
router.get("/id/:id", positionController.getById);

// Tạo mới vị trí
router.post("/", positionController.create);

// Cập nhật vị trí theo id
router.put("/:id", positionController.update);

// Xóa vị trí theo id
router.delete("/:id", positionController.delete);

module.exports = router;
