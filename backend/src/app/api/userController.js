const { User } = require("../models");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

class UserController {
  // Lấy danh sách tất cả người dùng
  async getAll(req, res) {
    try {
      const users = await User.findAll();
      res.status(200).json(users);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // Lấy thông tin người dùng theo user_id (UUID)
  async getById(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findOne({ where: { user_id: id } });

      if (!user) {
        return res.status(404).json({ error: "Người dùng không tồn tại" });
      }

      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin người dùng" });
    }
  }

  // Đăng ký người dùng mới
  async register(req, res) {
    try {
      const {
        user_id,
        email,
        phone,
        full_name,
        password_hash,
        avatar_url,
        gender,
      } = req.body;
      console.log(email);
      // Kiểm tra email đã tồn tại chưa
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({ error: "Email đã được sử dụng" });
      }

      const hashedPassword = await bcrypt.hash(password_hash, 10);

      const newUser = await User.create({
        user_id,
        email,
        phone,
        full_name,
        password_hash: hashedPassword,
        avatar_url,
        gender,
      });

      res.status(201).json(newUser);
    } catch (error) {
      console.log(error);
      res.status(500).json({ error: "Lỗi khi đăng ký người dùng" });
    }
  }

  // Đăng nhập người dùng
  async login(req, res) {
    const { email, password } = req.body;
    try {
      const user = await User.findOne({ where: { email } });
      if (!user) {
        return res.status(404).json({
          message: "Sai tên đăng nhập hoặc mật khẩu",
          response: false,
        });
      }

      const isMatch = await bcrypt.compare(password, user.password_hash);
      if (!isMatch) {
        return res.status(401).json({
          message: "Sai tên đăng nhập hoặc mật khẩu",
          response: false,
        });
      }

      // 🔹 Tạo Access Token (hết hạn sau 1 giờ)
      const accessToken = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: "1h" }
      );

      // 🔹 Tạo Refresh Token (hết hạn sau 7 ngày)
      const refreshToken = jwt.sign(
        { id: user.id },
        process.env.JWT_REFRESH_SECRET,
        { expiresIn: "7d" }
      );

      // 🏷️ Lưu các thông tin vào cookie
      const cookieOptions = {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "Lax",
        path: "/",
      };

      res.cookie("refreshToken", refreshToken, cookieOptions);
      res.cookie("accessToken", accessToken, cookieOptions);

      // ✅ Thêm userRole và userName vào cookie
      res.cookie("userRole", user.role, { ...cookieOptions, httpOnly: false });
      res.cookie("userName", user.name, { ...cookieOptions, httpOnly: false });

      res.status(200).json({
        message: "Đăng nhập thành công",
        response: true,
        accessToken,
        refreshToken,
        user: user,
      });
    } catch (error) {
      console.error("Error:", error);
      res.status(500).json({ message: "Đã xảy ra lỗi: " + error.message });
    }
  }

  async refreshToken(req, res) {
    try {
      const refreshToken = req.cookies.refreshToken;
      if (!refreshToken) {
        return res
          .status(401)
          .json({ message: "Không có refresh token", response: false });
      }

      jwt.verify(
        refreshToken,
        process.env.JWT_REFRESH_SECRET,
        async (err, decoded) => {
          if (err) {
            return res
              .status(403)
              .json({ message: "Refresh token không hợp lệ", response: false });
          }

          const user = await User.findByPk(decoded.id);
          if (!user) {
            return res
              .status(404)
              .json({ message: "Người dùng không tồn tại", response: false });
          }

          // 🔹 Tạo Access Token mới (hết hạn sau 1 giờ)
          const newAccessToken = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: "1h" }
          );

          res.cookie("accessToken", newAccessToken, {
            httpOnly: true,
            secure: process.env.NODE_ENV === "production",
            sameSite: "Lax",
            path: "/",
          });

          return res.status(200).json({
            message: "Refresh token thành công",
            response: true,
            accessToken: newAccessToken,
          });
        }
      );
    } catch (error) {
      console.error("Error:", error);
      res.status(500).json({ message: "Đã xảy ra lỗi: " + error.message });
    }
  }

  // Cập nhật người dùng theo user_id
  async update(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findOne({ where: { user_id: id } });

      if (!user) {
        return res.status(404).json({ error: "Người dùng không tồn tại" });
      }

      const { email, phone, full_name, password_hash, avatar_url, gender } =
        req.body;

      await user.update({
        email: email ?? user.email,
        phone: phone ?? user.phone,
        full_name: full_name ?? user.full_name,
        password_hash: password_hash ?? user.password_hash,
        avatar_url: avatar_url ?? user.avatar_url,
        gender: gender ?? user.gender,
      });

      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật người dùng" });
    }
  }

  // Xóa người dùng theo user_id
  async delete(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findOne({ where: { user_id: id } });

      if (!user) {
        return res.status(404).json({ error: "Người dùng không tồn tại" });
      }

      await user.destroy();
      res.status(200).json({ message: "Xóa người dùng thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa người dùng" });
    }
  }
}

module.exports = new UserController();
