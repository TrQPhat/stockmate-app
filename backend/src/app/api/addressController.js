const { Address } = require("../models");

class AddressController {
  // Lấy danh sách địa chỉ của người dùng
  async getUserAddresses(req, res) {
    const { user_id } = req.params;

    try {
      const addresses = await Address.findAll({ where: { user_id } });
      return res.status(200).json({
        success: true,
        message: "Lấy danh sách địa chỉ thành công",
        addresses,
      });
    } catch (error) {
      console.error("Lỗi khi lấy danh sách địa chỉ:", error);
      return res.status(500).json({
        success: false,
        message: "Lỗi hệ thống khi lấy danh sách địa chỉ",
        error: error.message,
      });
    }
  }

  // Thêm địa chỉ mới
  async addAddress(req, res) {
    const {
      user_id,
      recipient_name,
      phone,
      address_line,
      city,
      district,
      ward,
      address_type,
      note,
      is_default,
    } = req.body;

    try {
      // Nếu địa chỉ là mặc định, cập nhật các địa chỉ khác thành không mặc định
      if (is_default) {
        await Address.update({ is_default: false }, { where: { user_id } });
      }

      const newAddress = await Address.create({
        user_id,
        recipient_name,
        phone,
        address_line,
        city,
        district,
        ward,
        address_type,
        note,
        is_default,
      });

      return res.status(201).json({
        success: true,
        message: "Thêm địa chỉ mới thành công",
        address: newAddress,
      });
    } catch (error) {
      console.error("Lỗi khi thêm địa chỉ:", error);
      return res.status(500).json({
        success: false,
        message: "Lỗi hệ thống khi thêm địa chỉ",
        error: error.message,
      });
    }
  }

  // Cập nhật địa chỉ
  async updateAddress(req, res) {
    const { id } = req.params;
    const {
      recipient_name,
      phone,
      address_line,
      city,
      district,
      ward,
      address_type,
      note,
      is_default,
    } = req.body;

    try {
      const address = await Address.findByPk(id);

      if (!address) {
        return res.status(404).json({
          success: false,
          message: "Địa chỉ không tồn tại",
        });
      }

      // Nếu địa chỉ là mặc định, cập nhật các địa chỉ khác thành không mặc định
      if (is_default) {
        await Address.update(
          { is_default: false },
          { where: { user_id: address.user_id } }
        );
      }

      await address.update({
        recipient_name,
        phone,
        address_line,
        city,
        district,
        ward,
        address_type,
        note,
        is_default,
      });

      return res.status(200).json({
        success: true,
        message: "Cập nhật địa chỉ thành công",
        address,
      });
    } catch (error) {
      console.error("Lỗi khi cập nhật địa chỉ:", error);
      return res.status(500).json({
        success: false,
        message: "Lỗi hệ thống khi cập nhật địa chỉ",
        error: error.message,
      });
    }
  }

  // Xóa địa chỉ
  async deleteAddress(req, res) {
    const { id } = req.params;

    try {
      const address = await Address.findByPk(id);

      if (!address) {
        return res.status(404).json({
          success: false,
          message: "Địa chỉ không tồn tại",
        });
      }

      await address.destroy();

      return res.status(200).json({
        success: true,
        message: "Xóa địa chỉ thành công",
      });
    } catch (error) {
      console.error("Lỗi khi xóa địa chỉ:", error);
      return res.status(500).json({
        success: false,
        message: "Lỗi hệ thống khi xóa địa chỉ",
        error: error.message,
      });
    }
  }
}

module.exports = new AddressController();
