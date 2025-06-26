const { Grocery } = require("../models");

class GroceryController {
  // Lấy danh sách tất cả sản phẩm
  async getAllGroceries(req, res) {
    try {
      const grocerys = await Grocery.findAll();
      res.status(200).json(grocerys);
    } catch (error) {
      res.status(500).json({
        error: "Lỗi khi lấy danh sách sản phẩm",
        detail: error.message,
      });
    }
  }

  // Lấy thông tin sản phẩm theo id
  async getGroceryById(req, res) {
    try {
      const { id } = req.params;
      const grocery = await Grocery.findByPk(id);
      if (!grocery) {
        return res.status(404).json({ error: "Sản phẩm không tồn tại" });
      }
      res.status(200).json(grocery);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin sản phẩm" });
    }
  }

  // Tạo mới sản phẩm
  async createGrocery(req, res) {
    try {
      const {
        storage_id,
        name,
        category_id,
        quantity,
        unit,
        import_date,
        expire_date,
        note,
        status,
        position_id,
        image_path,
      } = req.body;
      console.log("Creating product with data:", req.body);
      const newGrocery = await Grocery.create({
        storage_id,
        name,
        category_id,
        quantity,
        unit,
        import_date,
        expire_date,
        note,
        status,
        position_id,
        image_path,
      });
      console.log("Grocery created:", newGrocery);
      res.status(201).json(newGrocery);
    } catch (error) {
      console.error("Error creating product:", error.errors || error.message);
      res.status(500).json({
        error: "Lỗi khi tạo sản phẩm",
        detail: error.errors?.map((e) => e.message) || error.message,
      });
    }
  }

  // Cập nhật sản phẩm theo id
  async updateGrocery(req, res) {
    try {
      const { id } = req.params;
      const grocery = await Grocery.findByPk(id);
      if (!grocery) {
        return res.status(404).json({ error: "Sản phẩm không tồn tại" });
      }

      const {
        storage_id,
        name,
        category_id,
        quantity,
        unit,
        import_date,
        expire_date,
        note,
        status,
        position_id,
        image_path,
      } = req.body;

      grocery.storage_id = storage_id ?? grocery.storage_id;
      grocery.name = name ?? grocery.name;
      grocery.category_id = category_id ?? grocery.category_id;
      grocery.quantity = quantity ?? grocery.quantity;
      grocery.unit = unit ?? grocery.unit;
      grocery.import_date = import_date ?? grocery.import_date;
      grocery.expire_date = expire_date ?? grocery.expire_date;
      grocery.note = note ?? grocery.note;
      grocery.status = status ?? grocery.status;
      grocery.image_path = image_path ?? grocery.image_path;
      grocery.updated_at = new Date();

      await grocery.save();

      res.status(200).json(grocery);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật sản phẩm" });
    }
  }

  // Xóa sản phẩm theo id
  async deleteGrocery(req, res) {
    try {
      const { id } = req.params;
      const grocery = await Grocery.findByPk(id);
      if (!grocery) {
        return res.status(404).json({ error: "Sản phẩm không tồn tại" });
      }

      await grocery.destroy();

      res.status(200).json({ message: "Xóa sản phẩm thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa sản phẩm" });
    }
  }
}

module.exports = new GroceryController();
