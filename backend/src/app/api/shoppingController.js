const { ShoppingList, ShoppingListItem, Product } = require("../models");
const { v4: uuidv4 } = require('uuid');

// Hàm trợ giúp kiểm tra quyền sở hữu
const checkOwnership = async (listId, userId) => {
    const list = await ShoppingList.findOne({ where: { id: listId, user_id: userId } });
    return list;
};


class ShoppingController {
    //--- QUẢN LÝ DANH SÁCH MUA SẮM ---

    async getAllLists(req, res) {
        try {
            const userId = req.user.id; // Lấy từ decoded token
            const userUUID = req.user.user_id;
            const lists = await ShoppingList.findAll({ where: { user_id: userUUID } });
            res.status(200).json(lists);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi lấy danh sách mua sắm." });
        }
    }

    async createList(req, res) {
        try {
            const { id, name } = req.body;
            const userUUID = req.user.user_id; // Lấy từ decoded token
            const newList = await ShoppingList.create({
                id,
                name,
                user_id: userUUID
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
            const { name } = req.body;
            list.name = name ?? list.name;
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
            await list.destroy(); // Sequelize sẽ tự động xóa các items liên quan nếu có 'onDelete: CASCADE'
            res.status(200).json({ message: "Xóa danh sách thành công." });
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi xóa danh sách." });
        }
    }

    //--- QUẢN LÝ CÁC MẶT HÀNG TRONG DANH SÁCH ---

    async addItemToList(req, res) {
        try {
            const { listId } = req.params;
            const userUUID = req.user.user_id;
            if (!await checkOwnership(listId, userUUID)) {
                return res.status(404).json({ error: "Danh sách không tồn tại hoặc bạn không có quyền truy cập." });
            }

            const { product_id, item_name, quantity, unit } = req.body;
            let finalItemName = item_name;

            // Nếu có product_id, tự động lấy tên từ sản phẩm
            if (product_id) {
                const product = await Product.findByPk(product_id);
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
                unit
            });
            res.status(201).json(newItem);

        } catch (error) {
            res.status(500).json({ error: "Lỗi khi thêm mặt hàng." });
        }
    }

    async updateItemInList(req, res) {
        try {
            const { listId, itemId } = req.params;
            const userUUID = req.user.user_id;
            if (!await checkOwnership(listId, userUUID)) {
                return res.status(404).json({ error: "Danh sách không tồn tại hoặc bạn không có quyền truy cập." });
            }

            const item = await ShoppingListItem.findOne({ where: { id: itemId, shopping_list_id: listId } });
            if (!item) {
                return res.status(404).json({ error: "Mặt hàng không tồn tại trong danh sách này." });
            }

            const { quantity, unit, is_purchased, item_name } = req.body;
            item.quantity = quantity ?? item.quantity;
            item.unit = unit ?? item.unit;
            item.is_purchased = is_purchased ?? item.is_purchased;
            item.item_name = item_name ?? item.item_name;

            await item.save();
            res.status(200).json(item);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi cập nhật mặt hàng." });
        }
    }

    async deleteItemFromList(req, res) {
        try {
            const { listId, itemId } = req.params;
            const userUUID = req.user.user_id;
            if (!await checkOwnership(listId, userUUID)) {
                return res.status(404).json({ error: "Danh sách không tồn tại hoặc bạn không có quyền truy cập." });
            }
            const item = await ShoppingListItem.findOne({ where: { id: itemId, shopping_list_id: listId } });
            if (!item) {
                return res.status(404).json({ error: "Mặt hàng không tồn tại trong danh sách này." });
            }
            await item.destroy();
            res.status(200).json({ message: "Xóa mặt hàng thành công." });
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi xóa mặt hàng." });
        }
    }
}

module.exports = new ShoppingController();