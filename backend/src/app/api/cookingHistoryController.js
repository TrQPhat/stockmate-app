const { CookingHistory, Dish, User } = require("../models");
const { v4: uuidv4 } = require("uuid");

class CookingHistoryController {
    /**
     * Ghi lại việc một món ăn đã được nấu
     */
    async logCookedDish(req, res) {
        try {
            const { dish_id, notes } = req.body;
            const user_id = req.user.user_id; // Lấy từ token

            // Kiểm tra xem món ăn có tồn tại không
            const dish = await Dish.findByPk(dish_id);
            if (!dish) {
                return res.status(404).json({ error: "Món ăn không tồn tại." });
            }

            const newLog = await CookingHistory.create({
                id: uuidv4(),
                dish_id,
                user_id,
                notes,
            });

            res.status(201).json(newLog);
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: "Lỗi khi ghi lại lịch sử nấu ăn." });
        }
    }

    /**
     * Lấy lịch sử nấu ăn của người dùng đang đăng nhập
     */
    async getUserCookingHistory(req, res) {
        try {
            const user_id = req.user.user_id;

            const history = await CookingHistory.findAll({
                where: { user_id },
                include: [
                    {
                        model: User,
                        attributes: ["full_name"], // Lấy tên người nấu
                    },
                    {
                        model: Dish,
                        attributes: ["name", "image_url"], // Chỉ lấy các trường cần thiết từ Dish
                    },

                ],
                order: [["cooked_at", "DESC"]], // Sắp xếp theo ngày nấu gần nhất
            });

            res.status(200).json(history);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi lấy lịch sử nấu ăn." });
        }
    }
}

module.exports = new CookingHistoryController();