const { Product } = require("../models");

class ProductController {
  // Lấy danh sách tất cả sản phẩm
  async getAllProducts(req, res) {
    try {
      const products = await Product.findAll();
      res.status(200).json(products);
    } catch (error) {
      res.status(500).json({
        error: "Lỗi khi lấy danh sách sản phẩm",
        detail: error.message,
      });
    }
  }

  // Lấy thông tin sản phẩm theo id
  async getProductById(req, res) {
    try {
      const { id } = req.params;
      const product = await Product.findByPk(id);
      if (!product) {
        return res.status(404).json({ error: "Sản phẩm không tồn tại" });
      }
      res.status(200).json(product);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin sản phẩm" });
    }
  }

  // Tạo mới sản phẩm
  async createProduct(req, res) {
    try {
      const {
        id,
        storage_id,
        name,
        category,
        quantity,
        unit,
        import_date,
        expire_date,
        note,
        status,
        image_path,
      } = req.body;

      const newProduct = await Product.create({
        id,
        storage_id,
        name,
        category,
        quantity,
        unit,
        import_date,
        expire_date,
        note,
        status,
        image_path,
      });

      res.status(201).json(newProduct);
    } catch (error) {
      res
        .status(500)
        .json({ error: "Lỗi khi tạo sản phẩm", detail: error.message });
    }
  }

  // Cập nhật sản phẩm theo id
  async updateProduct(req, res) {
    try {
      const { id } = req.params;
      const product = await Product.findByPk(id);
      if (!product) {
        return res.status(404).json({ error: "Sản phẩm không tồn tại" });
      }

      const {
        storage_id,
        name,
        category,
        quantity,
        unit,
        import_date,
        expire_date,
        note,
        status,
        image_path,
      } = req.body;

      product.storage_id = storage_id ?? product.storage_id;
      product.name = name ?? product.name;
      product.category = category ?? product.category;
      product.quantity = quantity ?? product.quantity;
      product.unit = unit ?? product.unit;
      product.import_date = import_date ?? product.import_date;
      product.expire_date = expire_date ?? product.expire_date;
      product.note = note ?? product.note;
      product.status = status ?? product.status;
      product.image_path = image_path ?? product.image_path;
      product.updated_at = new Date();

      await product.save();

      res.status(200).json(product);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật sản phẩm" });
    }
  }

  // Xóa sản phẩm theo id
  async deleteProduct(req, res) {
    try {
      const { id } = req.params;
      const product = await Product.findByPk(id);
      if (!product) {
        return res.status(404).json({ error: "Sản phẩm không tồn tại" });
      }

      await product.destroy();

      res.status(200).json({ message: "Xóa sản phẩm thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa sản phẩm" });
    }
  }
}

module.exports = new ProductController();
