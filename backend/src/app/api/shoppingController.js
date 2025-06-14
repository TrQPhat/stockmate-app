const { ShoppingList, ShoppingListItem, Product, sequelize } = require("../models");
const { v4: uuidv4 } = require('uuid');

// Hàm trợ giúp kiểm tra quyền sở hữu
const checkOwnership = async (listId, userId) => {
    const list = await ShoppingList.findOne({ where: { id: listId, user_id: userId } });
    return list;
};

// Hàm mới: Tính và cập nhật tổng tiền cho danh sách
const updateTotalCost = async (listId, transaction) => {
    const items = await ShoppingListItem.findAll({
        where: { shopping_list_id: listId },
        transaction
    });

    const totalCost = items.reduce((total, item) => {
        // Chỉ tính tiền cho những món đã được đánh dấu là "đã mua"
        if (item.is_purchased) {
            return total + (parseFloat(item.price) * item.quantity);
        }
        return total;
    }, 0);

    await ShoppingList.update(
        { total_cost: totalCost },
        { where: { id: listId }, transaction }
    );
};


class ShoppingController {
    //--- QUẢN LÝ DANH SÁCH MUA SẮM ---

    async getAllLists(req, res) {
        try {
            const userUUID = req.user.user_id;
            // Sắp xếp các danh sách theo ngày mua sắm, mới nhất lên đầu
            const lists = await ShoppingList.findAll({
                where: { user_id: userUUID },
                order: [['purchase_date', 'DESC']]
            });
            res.status(200).json(lists);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi lấy danh sách mua sắm." });
        }
    }

    async createList(req, res) {
        try {
            // Thêm purchase_date vào khi tạo list
            const { name, purchase_date } = req.body;
            const userUUID = req.user.user_id;
            const newList = await ShoppingList.create({
                id: uuidv4(),
                name,
                user_id: userUUID,
                purchase_date: purchase_date || new Date() // Nếu không cung cấp, lấy ngày hiện tại
            });
            res.status(201).json(newList);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi tạo danh sách mua sắm." });
        }
    }

    async getListById(req, res) {
        try {
            const userUUID = req.user.user_id;
            const list = await checkOwnership(req.params.listId, userUUID);
            if (!list) {
                return res.status(404).json({ error: "Danh sách không tồn tại hoặc bạn không có quyền truy cập." });
            }
            // Lấy thêm các items trong list
            const items = await ShoppingListItem.findAll({ where: { shopping_list_id: list.id } });
            res.status(200).json({ ...list.toJSON(), items });
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi lấy thông tin danh sách." });
        }
    }

     async updateList(req, res) {
        try {
            const userUUID = req.user.user_id;
            const list = await checkOwnership(req.params.listId, userUUID);
            if (!list) {
                return res.status(404).json({ error: "Danh sách không tồn tại hoặc bạn không có quyền truy cập." });
            }
            const { name, purchase_date } = req.body;
            list.name = name ?? list.name;
            list.purchase_date = purchase_date ?? list.purchase_date;
            list.updated_at = new Date();
            await list.save();
            res.status(200).json(list);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi cập nhật danh sách." });
        }
    }

    async deleteList(req, res) {
        try {
            const userUUID = req.user.user_id;
            const list = await checkOwnership(req.params.listId, userUUID);
            if (!list) {
                return res.status(404).json({ error: "Danh sách không tồn tại hoặc bạn không có quyền truy cập." });
            }
            // Sequelize sẽ tự động xóa các items liên quan nếu có 'onDelete: CASCADE'
            await list.destroy(); 
            res.status(200).json({ message: "Xóa danh sách thành công." });
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi xóa danh sách." });
        }
    }

    //--- QUẢN LÝ CÁC MẶT HÀNG TRONG DANH SÁCH ---

    async addItemToList(req, res) {
        const t = await sequelize.transaction();
        try {
            const { listId } = req.params;
            const userUUID = req.user.user_id;
            if (!await checkOwnership(listId, userUUID)) {
                await t.rollback();
                return res.status(404).json({ error: "Danh sách không tồn tại hoặc bạn không có quyền truy cập." });
            }
            // Thêm `price` khi tạo item
            const { product_id, item_name, quantity, unit, price } = req.body;
            let finalItemName = item_name;

            if (product_id) {
                const product = await Product.findByPk(product_id, { transaction: t });
                if (product) {
                    finalItemName = product.name;
                }
            }
            const newItem = await ShoppingListItem.create({
                id: uuidv4(),
                shopping_list_id: listId,
                product_id,
                item_name: finalItemName,
                quantity,
                unit,
                price // Lưu giá tiền
            }, { transaction: t });
            await t.commit();
            res.status(201).json(newItem);

        } catch (error) {
            await t.rollback();
            res.status(500).json({ error: "Lỗi khi thêm mặt hàng." });
        }
    }

    async updateItemInList(req, res) {
        const t = await sequelize.transaction();
        try {
            const { listId, itemId } = req.params;
            const userUUID = req.user.user_id;
            if (!await checkOwnership(listId, userUUID)) {
                await t.rollback();
                return res.status(404).json({ error: "Danh sách không tồn tại hoặc bạn không có quyền truy cập." });
            }

            const item = await ShoppingListItem.findOne({ where: { id: itemId, shopping_list_id: listId }, transaction: t });
            if (!item) {
                await t.rollback();
                return res.status(404).json({ error: "Mặt hàng không tồn tại trong danh sách này." });
            }

            // Thêm `price` vào các trường có thể cập nhật
            const { quantity, unit, is_purchased, item_name, price } = req.body;
            item.quantity = quantity ?? item.quantity;
            item.unit = unit ?? item.unit;
            item.is_purchased = is_purchased ?? item.is_purchased;
            item.item_name = item_name ?? item.item_name;
            item.price = price ?? item.price; // Cập nhật giá

            await item.save({ transaction: t });

            // Sau khi cập nhật, tính lại tổng tiền
            await updateTotalCost(listId, t);

            await t.commit();
            res.status(200).json(item);
        } catch (error) {
            await t.rollback();
            res.status(500).json({ error: "Lỗi khi cập nhật mặt hàng." });
        }
    }

    async deleteItemFromList(req, res) {
        const t = await sequelize.transaction();
        try {
            const { listId, itemId } = req.params;
            const userUUID = req.user.user_id;
            if (!await checkOwnership(listId, userUUID)) {
                await t.rollback();
                return res.status(404).json({ error: "Danh sách không tồn tại hoặc bạn không có quyền truy cập." });
            }
            const item = await ShoppingListItem.findOne({ where: { id: itemId, shopping_list_id: listId }, transaction: t });
            if (!item) {
                await t.rollback();
                return res.status(404).json({ error: "Mặt hàng không tồn tại trong danh sách này." });
            }
            await item.destroy({ transaction: t });

            // Sau khi xóa, tính lại tổng tiền
            await updateTotalCost(listId, t);

            await t.commit();
            res.status(200).json({ message: "Xóa mặt hàng thành công." });
        } catch (error) {
            await t.rollback();
            res.status(500).json({ error: "Lỗi khi xóa mặt hàng." });
        }
    }
}

module.exports = new ShoppingController();