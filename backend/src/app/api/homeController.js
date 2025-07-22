const { Grocery } = require("../models");
const { Op } = require("sequelize");

class HomeController {
  
    async getHomeStats(req, res) {
        try {
            const storageId = req.params.storage_id;

            if (!storageId) {
            return res.status(400).json({ error: "Missing storage_id" });
            }

            // Tổng số sản phẩm
            const totalProducts = await Grocery.count({
            where: {
                storage_id: storageId,
            },
            });

            const today = new Date();
            const nearExpiryDate = new Date();
            nearExpiryDate.setDate(today.getDate() + 3);

            // Sắp hết hạn: trong vòng 3 ngày tới và còn dùng được
            const nearExpiryCount = await Grocery.count({
            where: {
                storage_id: storageId,
                status: "con_dung",
                expire_date: {
                [Op.lte]: nearExpiryDate,
                [Op.gte]: today,
                },
            },
            });

            // Đã hết hạn: ngày hết hạn trước hôm nay và còn dùng được
            const expiredCount = await Grocery.count({
            where: {
                storage_id: storageId,
                status: "het_han",
                expire_date: {
                [Op.lt]: today,
                },
            },
            });

            return res.json({
            totalProducts,
            nearExpiry: nearExpiryCount,
            expired: expiredCount,
            });
        } catch (err) {
            console.error("Home stats error:", err);
            return res.status(500).json({ error: "Internal server error" });
        }
    }

}

module.exports = new HomeController();
