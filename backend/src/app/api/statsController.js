const { Grocery } = require("../models");
const { Category } = require("../models");
const { Op, fn, col, literal } = require("sequelize");

class StatsController {
  
    // Thống kê lãng phí theo storage_id
    async getWasteStats(req, res) {
        try {
            await Grocery.update(
                { status: 'het_han' },
                {
                    where: {
                    expire_date: { [Op.lt]: new Date() }, // nhỏ hơn hôm nay
                    status: { [Op.notIn]: ['huy', 'het_han'] }, // chưa bị đánh dấu
                    },
                }
            );
            const { storage_id } = req.params;

            if (!storage_id) {
            return res.status(400).json({ message: "Thiếu storage_id" });
            }

            // 1. Tổng số nguyên liệu trong kho
            const total = await Grocery.count({
            where: { storage_id },
            });

            // 2. Tổng số nguyên liệu lãng phí (status = het_han hoặc huy)
            const totalWaste = await Grocery.count({
            where: {
                storage_id,
                status: { [Op.in]: ["het_han", "huy"] },
            },
            });

            // 3. Tỉ lệ lãng phí
            const wasteRate = total === 0 ? 0 : (totalWaste / total) * 100;

            // 4. Chi tiết theo danh mục (group by category_id)
            const detailByCategory = await Grocery.findAll({
            where: { storage_id },
            attributes: [
                "category_id",
                [fn("COUNT", col("id")), "total"],
                [
                fn("SUM", literal(`CASE WHEN status IN ('het_han', 'huy') THEN 1 ELSE 0 END`)),
                "wasted",
                ],
            ],
            group: ["category_id"],
            raw: true,
            });

            // 5. Ghép tên danh mục nếu có bảng Category
            const results = await Promise.all(
            detailByCategory.map(async (item) => {
                const category = item.category_id
                ? await Category.findByPk(item.category_id)
                : null;
                return {
                category_id: item.category_id,
                category_name: category?.name || "Không xác định",
                total: parseInt(item.total),
                wasted: parseInt(item.wasted),
                wasteRate:
                    item.total == 0 ? 0 : +(item.wasted / item.total * 100).toFixed(2),
                };
            })
            );

            // 6. Trả kết quả JSON
            return res.json({
            storage_id: parseInt(storage_id),
            total,
            totalWaste,
            wasteRate: +wasteRate.toFixed(2),
            detailByCategory: results,
            });
        } catch (err) {
            console.error(err);
            return res.status(500).json({ message: "Có lỗi xảy ra khi thống kê." });
        }
    }


}

module.exports = new StatsController();
