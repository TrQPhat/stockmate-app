const { Product } = require("../models");
const { Op } = require("sequelize");

class ProductController {
  //   1. Lấy danh sách sản phẩm
  async getAllProductsAvailable(req, res) {
    try {
      let page = parseInt(req.params.page) || 1; // Mặc định là trang 1
      let limit = parseInt(req.params.limit) || 8;
      let offset = (page - 1) * limit; // Tính vị trí bắt đầu lấy sản phẩm

      // Lấy danh sách sản phẩm với pagination
      const { count, rows: products } = await Product.findAndCountAll({
        where: {
          isAvailable: true,
        },
        limit: limit,
        offset: offset,
      });

      res.status(200).json({
        response: true,
        products,
        currentPage: page,
        totalPages: Math.ceil(count / limit),
        totalProducts: count,
      });
    } catch (error) {
      res.status(500).json({ response: false, message: "Lỗi server", error });
    }
  }

  async getAllProducts(req, res) {
    try {
      let page = parseInt(req.params.page) || 1; // Mặc định là trang 1
      let limit = parseInt(req.params.limit) || 20;
      let offset = (page - 1) * limit; // Tính vị trí bắt đầu lấy sản phẩm

      // Lấy danh sách sản phẩm với pagination
      const { count, rows: products } = await Product.findAndCountAll({
        limit: limit,
        offset: offset,
      });

      res.status(200).json({
        response: true,
        products,
        currentPage: page,
        totalPages: Math.ceil(count / limit),
        totalProducts: count,
      });
    } catch (error) {
      res.status(500).json({ response: false, message: "Lỗi server", error });
    }
  }

  // Tìm kiếm sản phẩm theo tên
  async searchProducts(req, res) {
    try {
      const { q } = req.query; // Lấy query parameter 'q' từ URL

      if (!q) {
        return res.status(400).json({
          response: false,
          message: "Vui lòng nhập từ khóa tìm kiếm",
        });
      }

      // Tìm kiếm sản phẩm có tên chứa từ khóa (không phân biệt hoa thường)
      const products = await Product.findAll({
        where: {
          name: {
            [Op.like]: `%${q}%`, // Tìm kiếm mờ (fuzzy search)
          },
          isAvailable: true,
        },
        limit: 20, // Giới hạn kết quả trả về
      });

      res.status(200).json({
        response: true,
        products,
        message: `Tìm thấy ${products.length} sản phẩm phù hợp`,
      });
    } catch (error) {
      console.error("Lỗi khi tìm kiếm sản phẩm:", error);
      res.status(500).json({
        response: false,
        message: "Lỗi khi tìm kiếm sản phẩm",
        error: error.message,
      });
    }
  }

  //Sản phẩm nổi bật
  async getTopStockProducts(req, res) {
    try {
      const limit = 10; // Lấy top 10 sản phẩm
      const products = await Product.findAll({
        limit: limit,
        order: [["countInStock", "DESC"]],
        where: {
          isAvailable: true,
        },
      });

      res.status(200).json({
        response: true,
        products,
        message: "Top 10 sản phẩm có số lượng tồn kho lớn nhất",
      });
    } catch (error) {
      res.status(500).json({ response: false, message: "Lỗi server", error });
    }
  }

  //   2. Lấy chi tiết sản phẩm
  async getProductById(req, res) {
    try {
      const product = await Product.findByPk(req.params.id);
      if (!product)
        return res
          .status(404)
          .json({ response: false, message: "Sản phẩm không tồn tại" });

      res.status(200).json({ response: true, product });
    } catch (error) {
      res.status(500).json({ response: false, message: "Lỗi server", error });
    }
  }

  // Thêm sản phẩm (Admin)
  async createProduct(req, res) {
    try {
      // Kiểm tra nếu không có file ảnh được tải lên
      if (!req.file) {
        return res
          .status(400)
          .json({ response: false, message: "Vui lòng chọn ảnh sản phẩm!" });
      }

      // Lấy thông tin sản phẩm từ request body
      const { name, category_id, type, price, countInStock } = req.body;

      // Kiểm tra sản phẩm đã tồn tại chưa
      const existingProduct = await Product.findOne({ where: { name } });
      if (existingProduct) {
        return res
          .status(400)
          .json({ response: false, message: "Sản phẩm đã tồn tại!" });
      }

      // Tạo đường dẫn ảnh (lưu file vào thư mục 'uploads/')
      const imagePath = `${req.file.filename}`;

      // Lưu sản phẩm vào database với đường dẫn ảnh
      const newProduct = await Product.create({
        name,
        image: imagePath, // Lưu đường dẫn ảnh
        category_id,
        type,
        price,
        countInStock,
        isAvailable: true,
      });

      res.status(201).json({
        response: true,
        message: "Thêm sản phẩm thành công",
        product: newProduct,
      });
    } catch (error) {
      console.error("Lỗi khi thêm sản phẩm:", error);
      res.status(500).json({
        response: false,
        message: "Lỗi khi thêm sản phẩm",
        error: error.message,
      });
    }
  }

  // 4. Cập nhật sản phẩm (Admin)
  async updateProduct(req, res) {
    try {
      const { id } = req.params;
      const product = await Product.findByPk(id);

      if (!product) {
        return res.status(404).json({
          response: false,
          message: "Sản phẩm không tồn tại!",
        });
      }

      // Lấy thông tin sản phẩm từ request body
      const { name, category_id, type, price, countInStock } = req.body;
      console.log(countInStock);
      // Tạo một object để chứa dữ liệu cập nhật
      const updatedData = {};

      if (name) updatedData.name = name;
      else updatedData.name = product.name;
      if (category_id) updatedData.category_id = category_id;
      else updatedData.category_id = product.category_id;
      if (type) updatedData.type = type;
      else updatedData.type = product.type;
      if (price) updatedData.price = price;
      else updatedData.price = product.price;
      if (countInStock != 0 && countInStock != null)
        updatedData.countInStock = countInStock;
      else updatedData.countInStock = product.countInStock;

      // Kiểm tra và cập nhật ảnh (nếu có file được tải lên)
      if (req.file) {
        updatedData.image = req.file.filename; // Đường dẫn ảnh (hoặc xử lý tùy theo server)
        // Tạo đường dẫn ảnh (lưu file vào thư mục 'uploads/')
        updatedData.image = `${req.file.filename}`;
      } else updatedData.image = product.image;

      // Cập nhật sản phẩm
      await product.update(updatedData);

      res.status(200).json({
        response: true,
        message: "Cập nhật sản phẩm thành công!",
        product: updatedData,
      });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi cập nhật sản phẩm!",
        error: error.message,
      });
    }
  }

  //   Xóa sản phẩm (Admin)
  async deleteProduct(req, res) {
    try {
      const { id } = req.body;
      const product = await Product.findByPk(id);

      if (!product)
        return res.status(404).json({
          response: false,
          message: "Sản phẩm không tồn tại",
          id: 10,
        });

      await product.destroy();
      res
        .status(200)
        .json({ response: true, message: "Xóa sản phẩm thành công" });
    } catch (error) {
      res
        .status(500)
        .json({ response: false, message: "Lỗi khi xóa sản phẩm", error });
    }
  }
}

module.exports = new ProductController();
