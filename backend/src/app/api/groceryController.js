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

  async getExpiringGroceries(req, res) {
    try {
      const today = new Date();
      const threeDaysLater = new Date();
      threeDaysLater.setDate(today.getDate() + 3);

      const expiringGroceries = await Grocery.findAll({
        where: {
          expire_date: {
            $gte: today,
            $lte: threeDaysLater,
          },
        },
      });

      res.status(200).json(expiringGroceries);
    } catch (error) {
      res.status(500).json({
        error: "Lỗi khi lấy danh sách thực phẩm sắp hết hạn",
        detail: error.message,
      });
    }
  }

  // Lấy danh sách thực phẩm đã hết hạn
  async getExpiredGroceries(req, res) {
    try {
      const today = new Date();
      const expiredGroceries = await Grocery.findAll({
        where: {
          expire_date: { $lt: today },
        },
      });
      res.status(200).json(expiredGroceries);
    } catch (error) {
      res.status(500).json({
        error: "Lỗi khi lấy danh sách thực phẩm hết hạn",
        detail: error.message,
      });
    }
  }

  // Tạo mới sản phẩm
  async createGrocery(req, res) {
    try {
      // Kiểm tra nếu không có file ảnh được tải lên
      if (!req.file) {
        return res
          .status(400)
          .json({ response: false, message: "Vui lòng chọn ảnh sản phẩm!" });
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
        
      } = req.body;
      console.log("Creating product with data:", req.body);

      // Tạo đường dẫn ảnh (lưu file vào thư mục 'uploads/')
      const image_path = `${req.file.filename}`;
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

      // Kiểm tra và cập nhật ảnh (nếu có file được tải lên)
      if (req.file) {
        grocery.image_path = req.file.filename; // Đường dẫn ảnh (hoặc xử lý tùy theo server)
        // Tạo đường dẫn ảnh (lưu file vào thư mục 'uploads/')
        grocery.image_path = `${req.file.filename}`;
      } 

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

  //Thống kê lãng phí
  async getWasteStats(req, res) {
    try {
      // 1. Tổng số nguyên liệu
      const total = await Grocery.count();

      // 2. Tổng số nguyên liệu lãng phí (status = het_han hoặc huy)
      const totalWaste = await Grocery.count({
        where: {
          status: { [Op.in]: ["het_han", "huy"] },
        },
      });

      // 3. Tính tỉ lệ lãng phí
      const wasteRate = total === 0 ? 0 : (totalWaste / total) * 100;

      // 4. Chi tiết theo danh mục (group by category_id)
      const detailByCategory = await Grocery.findAll({
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

      // 5. Ghép thêm tên danh mục nếu có bảng Category
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
              item.total == 0 ? 0 : (item.wasted / item.total * 100).toFixed(2),
          };
        })
      );

      // 6. Trả kết quả JSON
      return res.json({
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

  async deleteMultipleGroceries(req, res) {
  try {
    const { ids } = req.body; // mong đợi mảng: [1, 2, 3]

    if (!Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ error: "Danh sách ID không hợp lệ" });
    }

    const deletedCount = await Grocery.destroy({
      where: {
        id: ids
      }
    });

    res.status(200).json({
      message: `Đã xóa ${deletedCount} sản phẩm thành công`,
    });
  } catch (error) {
    console.error("Lỗi khi xóa nhiều sản phẩm:", error);
    res.status(500).json({ error: "Lỗi khi xóa nhiều sản phẩm" });
  }
}
  


}

module.exports = new GroceryController();
