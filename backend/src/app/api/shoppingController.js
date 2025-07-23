const { ShoppingList, ShoppingItem, Grocery, sequelize } = require("../models");

class ShoppingController {
  // async getAllShoppingLists(req, res) {
  //   try {
  //     const { storageId } = req.params;

  //     if (!storageId) {
  //       return res.status(400).json({ error: "Vui lòng cung cấp ID của kho" });
  //     }

  //     const shoppingLists = await ShoppingList.findAll({
  //       where: { storage_id: storageId },
  //       order: [["purchase_date", "ASC"]],
  //     });

  //     res.json(shoppingLists);
  //   } catch (error) {
  //     console.log("Error fetching shopping lists:", error);
  //     res.status(500).json({
  //       error: "Quá trình truy vấn đã xảy ra vấn đề, vui lòng thử lại",
  //     });
  //   }
  // }

  async getAllShoppingLists(req, res) {
  try {
    const { storageId } = req.params;

    if (!storageId) {
      return res.status(400).json({ error: "Vui lòng cung cấp ID của kho" });
    }

    const shoppingLists = await ShoppingList.findAll({
      where: { storage_id: storageId },
      order: [["purchase_date", "ASC"]],
      include: [
        {
          model: ShoppingItem,
          as: "items",
          order: [["id", "ASC"]],
        },
      ],
    });

    res.json(shoppingLists);
  } catch (error) {
    console.log("Error fetching shopping lists:", error);
    res.status(500).json({
      error: "Quá trình truy vấn đã xảy ra vấn đề, vui lòng thử lại",
    });
  }
}


  async createList(req, res) {
    try {
      const { name, purpose, purchase_date, storage_id } = req.body;
      console.log("Creating product with data:", req.body);
      const newList = await ShoppingList.create({
        name,
        purpose,
        storage_id,
        purchase_date: new Date(purchase_date),
        created_at: new Date(),
      });

      res.status(201).json(newList);
    } catch (error) {
      console.error("Lỗi khi tạo danh sách:", error);
      res.status(500).json({ error: "Lỗi khi tạo danh sách mua sắm." });
    }
  }

  async getListById(req, res) {
    try {
      const { listId } = req.params;

      if (!listId) {
        return res.status(400).json({
          error: "Vui lòng cung cấp ID danh sách",
        });
      }

      const list = await ShoppingList.findByPk(listId, {
        include: [{ model: ShoppingItem, as: "items" }],
      });

      if (!list) {
        return res.status(404).json({ error: "Không tìm thấy danh sách" });
      }

      res.status(200).json(list.toJSON());
    } catch (error) {
      console.log("Error fetching shopping list:", error);
      res.status(500).json({
        error: "Quá trình truy vấn đã xảy ra vấn đề, vui lòng thử lại",
      });
    }
  }
  async updateList(req, res) {
    try {
      const { listId } = req.params;

      // Lấy từng trường từ body
      const { storage_id, name, purpose, purchase_date } = req.body;

      // Tìm bản ghi theo ID
      const list = await ShoppingList.findByPk(listId);
      if (!list) {
        return res.status(404).json({
          success: false,
          message: `Không tìm thấy danh sách cần mua với ID: ${listId}`,
        });
      }

      // Cập nhật các trường nếu có
      if (storage_id !== undefined) list.storage_id = storage_id;
      if (name !== undefined) list.name = name;
      if (purpose !== undefined) list.purpose = purpose;
      if (purchase_date !== undefined) {
        const parsedDate = new Date(purchase_date);
        if (isNaN(parsedDate.getTime())) {
          return res.status(400).json({
            success: false,
            message: "purchase_date không hợp lệ.",
          });
        }
        list.purchase_date = parsedDate;
      }

      list.updated_at = new Date(); // cập nhật thời gian chỉnh sửa

      await list.save();

      return res.json({
        success: true,
        message: "Cập nhật danh sách thành công.",
        data: list,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: `Lỗi khi cập nhật: ${error.message}`,
      });
    }
  }

  async deleteList(req, res) {
    try {
      const { listId } = req.params;

      // Tìm danh sách theo ID
      const list = await ShoppingList.findByPk(listId);

      if (!list) {
        return res.status(404).json({
          success: false,
          message: `Không tìm thấy danh sách với ID: ${listId}`,
        });
      }

      // Thực hiện xóa
      await list.destroy();

      return res.status(200).json({
        success: true,
        message: "Xóa danh sách thành công.",
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: `Lỗi khi xóa danh sách: ${error.message}`,
      });
    }
  }

  async addItemToList(req, res) {
    try {
      const {
        list_id,
        item_name,
        quantity,
        unit,
        expire,
        is_purchased,
        category_id,
      } = req.body;

      // Kiểm tra bắt buộc
      if (!list_id || !item_name || !category_id) {
        return res.status(400).json({ error: "Thiếu trường bắt buộc." });
      }

      const newItem = await ShoppingItem.create({
        list_id,
        item_name,
        quantity: quantity ?? 1, // fallback nếu null
        unit,
        expire: expire ? new Date(expire) : undefined,
        is_purchased: is_purchased ?? false,
        category_id,
      });

      res.status(201).json(newItem);
    } catch (error) {
      console.error("Lỗi khi thêm mục mua sắm:", error);
      res.status(500).json({ error: "Không thể thêm mục mua sắm." });
    }
  }

  async toggleItemPurchasedStatus(req, res) {
    try {
      const { itemId } = req.params;

      if (!itemId) {
        return res.status(400).json({ error: "Vui lòng cung cấp ID sản phẩm" });
      }

      // Tìm item theo ID
      const item = await ShoppingItem.findByPk(itemId);
      if (!item) {
        return res.status(404).json({ error: "Không tìm thấy mặt hàng" });
      }

      // Đảo trạng thái is_purchased
      item.is_purchased = !item.is_purchased;
      await item.save();

      return res.status(200).json({
        message: "Cập nhật trạng thái mua thành công",
        item: item.toJSON(),
      });
    } catch (error) {
      console.error("Lỗi khi cập nhật trạng thái mặt hàng:", error);
      res.status(500).json({ error: "Đã xảy ra lỗi, vui lòng thử lại" });
    }
  }

  async updateItemInList(req, res) {
    const t = await sequelize.transaction();
    try {
      const { listId, itemId } = req.params;
      const userId = req.user.user_id;
      const list = await checkOwnership(listId, userId);
      if (!list) {
        await t.rollback();
        return res.status(404).json({ error: "Không tìm thấy danh sách." });
      }

      const item = await ShoppingItem.findOne({
        where: { id: itemId, list_id: listId },
        transaction: t,
      });

      if (!item) {
        await t.rollback();
        return res.status(404).json({ error: "Không tìm thấy mặt hàng." });
      }

      const { quantity, unit, is_purchased, price } = req.body;
      item.quantity = quantity ?? item.quantity;
      item.unit = unit ?? item.unit;
      item.is_purchased = is_purchased ?? item.is_purchased;
      item.price = price ?? item.price;

      await item.save({ transaction: t });
      await updateTotalCost(listId, t);
      await t.commit();
      res.status(200).json(item);
    } catch (error) {
      await t.rollback();
      res.status(500).json({ error: "Lỗi khi cập nhật mặt hàng." });
    }
  }

  async deleteItemFromList(req, res) {
    try {
      const { id } = req.params;

      if (!id) {
        return res.status(400).json({ error: "Thiếu ID mục cần xoá." });
      }

      const deletedCount = await ShoppingItem.destroy({
        where: { id },
      });

      if (deletedCount === 0) {
        return res.status(404).json({ error: "Không tìm thấy mục cần xoá." });
      }

      res.status(200).json({ message: "Xoá mục mua sắm thành công." });
    } catch (error) {
      console.error("Lỗi khi xoá mục:", error);
      res.status(500).json({ error: "Không thể xoá mục mua sắm." });
    }
  }

  async completeShoppingList(req, res) {
    try {
      const { listId } = req.params;

      const shoppingList = await ShoppingList.findByPk(listId);
      if (!shoppingList) {
        return res.status(404).json({ error: "Không tìm thấy danh sách." });
      }

      const purchasedItems = await ShoppingItem.findAll({
        where: {
          list_id: listId,
          is_purchased: true,
        },
      });

      const groceryData = purchasedItems.map((item) => ({
        storage_id: shoppingList.storage_id,
        name: item.item_name,
        category_id: item.category_id,
        quantity: item.quantity,
        unit: item.unit,
        import_date: new Date(),
        expire_date: item.expire,
        status: "con_dung",
        created_at: new Date(),
      }));

      // Bulk insert vào bảng groceries
      await Grocery.bulkCreate(groceryData);

      // Xoá danh sách mua sắm (cascading xoá shopping_items)
      await ShoppingList.destroy({ where: { id: listId } });

      res.status(200).json({
        message: "Hoàn thành mua sắm và chuyển thực phẩm thành công.",
      });
    } catch (error) {
      console.error("Lỗi khi hoàn thành mua sắm:", error);
      res
        .status(500)
        .json({ error: "Không thể hoàn thành danh sách mua sắm." });
    }
  }
}

module.exports = new ShoppingController();
