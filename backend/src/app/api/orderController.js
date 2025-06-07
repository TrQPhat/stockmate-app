const {
  sequelize,
  Order,
  Product,
  OrderDetail,
  Payment,
  Delivery,
} = require("../models");

class OrderController {
  async createOrder(req, res) {
    const t = await sequelize.transaction();
    try {
      // 1. Validate dữ liệu đầu vào
      const {
        order_id,
        user_id,
        totalPrice,
        payment_method,
        deliveryAddress,
        products,
      } = req.body;
      console.log("order_id", order_id);
      if (
        !order_id ||
        !user_id ||
        !totalPrice ||
        !payment_method ||
        !deliveryAddress ||
        !products ||
        !products.length
      ) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          message: "Thiếu thông tin bắt buộc",
        });
      }

      // 2. Tạo transaction_id duy nhất
      const transaction_id = `txn_${Date.now()}_${Math.floor(
        Math.random() * 1000
      )}`;

      // 3. Tạo Payment với transaction_id
      const payment = await Payment.create(
        {
          payment_method: payment_method,
          payment_status:
            payment_method != "Thanh toán VNPay" ? "Pending" : "Paid",
          transaction_id: transaction_id,
        },
        { transaction: t }
      );

      // 4. Tạo Delivery
      const delivery = await Delivery.create(
        {
          address: deliveryAddress,
          status: "Processing",
        },
        { transaction: t }
      );

      // 5. Tạo Order
      const order = await Order.create(
        {
          id: order_id,
          user_id,
          payments_id: payment.id,
          deliveries_id: delivery.id,
          totalPrice,
          status: "Processing",
        },
        { transaction: t }
      );

      // 6. Thêm sản phẩm vào order_details
      for (const item of products) {
        const product = await Product.findByPk(item.product_id, {
          transaction: t,
        });
        if (!product) {
          await t.rollback();
          return res.status(404).json({
            success: false,
            message: `Sản phẩm với ID ${item.product_id} không tồn tại`,
          });
        }

        // Kiểm tra số lượng tồn kho
        if (product.stock < item.quantity) {
          await t.rollback();
          return res.status(400).json({
            success: false,
            message: `Sản phẩm ${product.name} không đủ số lượng tồn kho`,
          });
        }

        await OrderDetail.create(
          {
            order_id: order.id,
            product_id: item.product_id,
            quantity: item.quantity,
            price: product.price,
          },
          { transaction: t }
        );

        // Cập nhật số lượng tồn kho
        await Product.update(
          {
            stock: product.stock - item.quantity,
          },
          {
            where: { id: item.product_id },
            transaction: t,
          }
        );
      }

      // 7. Commit transaction nếu mọi thứ thành công
      await t.commit();

      return res.status(201).json({
        success: true,
        message: "Tạo đơn hàng thành công",
        order_id: order.id + "",
        payment_id: payment.id,
        delivery_id: delivery.id,
      });
    } catch (error) {
      // 8. Rollback transaction nếu có lỗi
      if (t && !t.finished) {
        await t.rollback();
      }

      console.error("Lỗi khi tạo đơn hàng:", error);

      return res.status(500).json({
        success: false,
        message: "Lỗi hệ thống khi tạo đơn hàng",
        error:
          process.env.NODE_ENV === "development" ? error.message : undefined,
      });
    }
  }

  // Cập nhật trạng thái thanh toán
  async updatePaymentStatus(req, res) {
    try {
      const { id } = req.params;
      const order = await Order.findByPk(id);

      if (!order) {
        return res
          .status(404)
          .json({ response: false, message: "Đơn hàng không tồn tại" });
      }

      order.isPaid = true;
      order.paidAt = new Date();
      await order.save();

      res.status(200).json({
        response: true,
        message: "Cập nhật trạng thái thanh toán thành công",
        order,
      });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi cập nhật thanh toán",
        error: error.message,
      });
    }
  }

  // Cập nhật trạng thái giao hàng
  async updateDeliveryStatus(req, res) {
    try {
      const { id } = req.params;
      const order = await Order.findByPk(id);

      if (!order) {
        return res
          .status(404)
          .json({ response: false, message: "Đơn hàng không tồn tại" });
      }

      order.deliveredAt = new Date();
      await order.save();

      res.status(200).json({
        response: true,
        message: "Cập nhật trạng thái giao hàng thành công",
        order,
      });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi cập nhật trạng thái giao hàng",
        error: error.message,
      });
    }
  }

  // Xóa đơn hàng (Admin)
  async deleteOrder(req, res) {
    try {
      const { id } = req.params;
      const order = await Order.findByPk(id);

      if (!order) {
        return res
          .status(404)
          .json({ response: false, message: "Đơn hàng không tồn tại" });
      }

      const payment = await Payment.findByPk(order.payments_id);
      const delivery = await Delivery.findByPk(order.deliveries_id);

      await order.destroy();
      await payment.destroy();
      await delivery.destroy();

      res.status(200).json({
        response: true,
        message: "Xóa đơn hàng thành công",
      });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi xóa đơn hàng",
        error: error.message,
      });
    }
  }

  async cancelOrder(req, res) {
    try {
      const { id } = req.params;
      const order = await Order.findByPk(id);

      if (!order) {
        return res
          .status(404)
          .json({ response: false, message: "Đơn hàng không tồn tại" });
      }

      // Kiểm tra trạng thái đơn hàng
      if (order.status !== "processing") {
        return res.status(400).json({
          response: false,
          message: "Không thể hủy, đơn hàng đã được giao hoặc đã hủy",
        });
      }

      // Cập nhật trạng thái đơn hàng thành "Cancelled"
      order.status = "Cancelled";
      await order.save();

      res.status(200).json({
        response: true,
        message: "Hủy đơn hàng thành công",
      });
    } catch (error) {
      res.status(500).json({
        response: false,
        message: "Lỗi khi hủy đơn hàng",
        error: error.message,
      });
    }
  }

  async getOrdersInProcess(req, res) {
    const { user_id } = req.params;

    try {
      // Lấy danh sách đơn hàng với trạng thái "Processing" hoặc "Delivering"
      const orders = await Order.findAll({
        where: {
          user_id,
          status: ["Processing", "Delivering"], // Lọc theo trạng thái
        },
        include: [
          {
            model: OrderDetail,
            include: [
              {
                model: Product,
                attributes: ["name"], // Chỉ lấy tên món ăn
              },
            ],
          },
        ],
        order: [["createdAt", "DESC"]], // Sắp xếp theo ngày đặt hàng mới nhất
      });

      // Định dạng dữ liệu trả về
      const formattedOrders = orders.map((order) => ({
        order_id: order.id,
        createdAt: order.createdAt,
        status: order.status,
        totalPrice: order.OrderDetails.reduce(
          (total, detail) => total + detail.price * detail.quantity,
          0
        ), // Tính tổng tiền hóa đơn
        products: order.OrderDetails.map((detail) => detail.Product.name), // Chỉ lấy danh sách tên món ăn
      }));

      return res.status(200).json({
        success: true,
        message: "Lấy danh sách đơn hàng thành công",
        orders: formattedOrders,
      });
    } catch (error) {
      console.error("Lỗi khi lấy danh sách đơn hàng:", error);
      return res.status(500).json({
        success: false,
        message: "Lỗi hệ thống khi lấy danh sách đơn hàng",
        error: error.message,
      });
    }
  }

  async getOrdersHistory(req, res) {
    const { user_id } = req.params;

    try {
      // Lấy danh sách đơn hàng với trạng thái "Processing" hoặc "Delivering"
      const orders = await Order.findAll({
        where: {
          user_id,
          status: ["completed", "cancelled"], // Lọc theo trạng thái
        },
        include: [
          {
            model: OrderDetail,
            include: [
              {
                model: Product,
                attributes: ["name"], // Chỉ lấy tên món ăn
              },
            ],
          },
        ],
        order: [["createdAt", "DESC"]], // Sắp xếp theo ngày đặt hàng mới nhất
      });

      // Định dạng dữ liệu trả về
      const formattedOrders = orders.map((order) => ({
        order_id: order.id,
        createdAt: order.createdAt,
        status: order.status,
        totalPrice: order.OrderDetails.reduce(
          (total, detail) => total + detail.price * detail.quantity,
          0
        ), // Tính tổng tiền hóa đơn
        products: order.OrderDetails.map((detail) => detail.Product.name), // Chỉ lấy danh sách tên món ăn
      }));

      return res.status(200).json({
        success: true,
        message: "Lấy danh sách đơn hàng thành công",
        orders: formattedOrders,
      });
    } catch (error) {
      console.error("Lỗi khi lấy danh sách đơn hàng:", error);
      return res.status(500).json({
        success: false,
        message: "Lỗi hệ thống khi lấy danh sách đơn hàng",
        error: error.message,
      });
    }
  }
}

module.exports = new OrderController();
