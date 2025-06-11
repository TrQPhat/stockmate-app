const express = require("express");
const router = express.Router();
const storageMemberController = require("../app/api/storageMemberController");
const authToken = require("../middleware/authToken");

// Lấy danh sách tất cả storage members
router.get("/", authToken, storageMemberController.getAllStorageMembers);

// Lấy một storage member theo id
router.get("/:id", authToken, storageMemberController.getStorageMemberById);

// Tạo mới storage member
router.post("/", authToken, storageMemberController.createStorageMember);

// Cập nhật storage member theo id
router.put("/:id", authToken, storageMemberController.updateStorageMember);

// Xóa storage member theo id
router.delete("/:id", authToken, storageMemberController.deleteStorageMember);

module.exports = router;
