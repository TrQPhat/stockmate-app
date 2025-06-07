const { Cart, Product } = require("../models");

class CartController {
  constructor() {}

  // Lấy danh sách giỏ hàng của người dùng
  async getCart(req, res) {
    const { user_id } = req.params;
    Cart.findAll({
      where: { user_id },
      include: [{ model: Product, attributes: ["name", "price", "image"] }],
    })
      .then((cartItems) => {
        res.status(200).json({ response: true, data: cartItems });
      })
      .catch((error) => {
        res.status(500).json({
          response: false,
          message: "Lỗi khi lấy giỏ hàng",
          error: error.message,
        });
      });
  }

  // Thêm sản phẩm vào giỏ hàng
  // Thêm sản phẩm vào giỏ hàng
  async addToCart(req, res) {
    const { user_id, product_id, quantity } = req.body;

    try {
      let cartItem = await Cart.findOne({
        where: { user_id, product_id },
      });

      if (cartItem) {
        cartItem.quantity += Number(quantity); // Cộng dồn số lượng
        await cartItem.save();
      } else {
        cartItem = await Cart.create({
          user_id,
          product_id,
          quantity: Number(quantity),
        });
      }

      // Lấy thông tin sản phẩm liên quan
      const product = await Product.findOne({
        where: { id: product_id },
        attributes: ["name", "price", "image"], // Chỉ lấy các trường cần thiết
      });

      res.status(201).json({
        id: cartItem.id,
        user_id: cartItem.user_id,
        product_id: cartItem.product_id,
        quantity: cartItem.quantity,
        Product: product, // Thông tin sản phẩm
      });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi thêm sản phẩm vào giỏ hàng",
        error: error.message,
      });
    }
  }

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  async updateCart(req, res) {
    const { user_id, cart_id, quantity } = req.body;

    try {
      // Kiểm tra xem sản phẩm có trong giỏ hàng không
      const cartItem = await Cart.findOne({
        where: { user_id, id: cart_id },
      });

      if (!cartItem) {
        return res.status(404).json({
          response: false,
          message: "Sản phẩm không tồn tại trong giỏ hàng",
        });
      }

      // Nếu `quantity` <= 0, xóa sản phẩm khỏi giỏ hàng
      if (quantity <= 0) {
        await cartItem.destroy();
        return res.status(200).json({
          response: true,
          message: "Sản phẩm đã bị xóa khỏi giỏ hàng",
        });
      }

      // Cập nhật số lượng sản phẩm
      cartItem.quantity = quantity;
      await cartItem.save();

      // Lấy thông tin sản phẩm liên quan
      const product = await Product.findOne({
        where: { id: cartItem.product_id },
        attributes: ["name", "price", "image"], // Chỉ lấy các trường cần thiết
      });

      return res.status(200).json({
        id: cartItem.id,
        user_id: cartItem.user_id,
        product_id: cartItem.product_id,
        quantity: cartItem.quantity,
        Product: product, // Thông tin sản phẩm
      });
    } catch (error) {
      console.error("Lỗi cập nhật giỏ hàng:", error);
      return res.status(500).json({
        response: false,
        message: "Lỗi khi cập nhật giỏ hàng",
        error: error.message,
      });
    }
  }

  //Xóa sản phẩm khỏi giỏ hàng
  async removeFromCart(req, res) {
    try {
      const { cart_id } = req.params;

      // Tìm sản phẩm trong giỏ hàng
      const cartItem = await Cart.findOne({ where: { id: cart_id } });

      if (!cartItem) {
        return res.status(404).json({
          response: false,
          message: "Sản phẩm trong giỏ hàng không tồn tại",
        });
      }

      // Xóa sản phẩm khỏi giỏ hàng
      await cartItem.destroy();

      return res.status(200).json({
        response: true,
        message: "Xóa sản phẩm khỏi giỏ hàng thành công",
      });
    } catch (error) {
      return res.status(500).json({
        response: false,
        message: "Lỗi khi xóa sản phẩm khỏi giỏ hàng",
        error: error.message,
      });
    }
  }

  async clearCart(req, res) {
    const { user_id } = req.params;

    Cart.destroy({ where: { user_id } })
      .then((deletedCount) => {
        if (deletedCount > 0) {
          res
            .status(200)
            .json({ response: true, message: "Đã xóa toàn bộ giỏ hàng" });
        } else {
          res.status(404).json({
            response: false,
            message: "Không tìm thấy giỏ hàng của người dùng",
          });
        }
      })
      .catch((error) => {
        res.status(500).json({
          response: false,
          message: "Lỗi khi xóa giỏ hàng",
          error: error.message,
        });
      });
  }

  // lấy tổng số lượng sản phẩm trong giỏ hàng
  async getTotalItems(req, res) {
    const { user_id } = req.params;

    Cart.sum("quantity", { where: { user_id } })
      .then((totalItems) => {
        res.status(200).json({ response: true, totalItems });
      })
      .catch((error) => {
        res.status(500).json({
          response: false,
          message: "Lỗi khi lấy tổng số lượng sản phẩm trong giỏ hàng",
          error: error.message,
        });
      });
  }
}

module.exports = new CartController();
