const { User, StorageMember, Storage } = require("../models");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { v4: uuidv4 } = require("uuid");

class UserController {
  async getAll(req, res) {
    try {
      const users = await User.findAll();
      res.status(200).json(users);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findByPk(id);
      if (!user) {
        return res.status(404).json({ error: "Người dùng không tồn tại" });
      }
      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin người dùng" });
    }
  }

  async register(req, res) {
    try {
      const { email, phone, full_name, password, avatar_url, gender } =
        req.body;
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({ error: "Email đã được sử dụng" });
      }
      const hashedPassword = await bcrypt.hash(password, 10);
      const newUser = await User.create({
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

  async verifyUser(req, res) {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: "Thiếu email để xác thực." });
    }

    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(404).json({ error: "Người dùng không tồn tại." });
    }

    if (user.status == 'active') {
      return res.status(200).json({ message: "Người dùng đã được xác thực trước đó." });
    }

    user.status = 'active';
    await user.save();

    res.status(200).json({ message: "Xác thực email thành công.", user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Lỗi khi xác thực người dùng." });
  }
}

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
      const accessToken = jwt.sign(
        { id: user.id, email: user.email },
        process.env.JWT_SECRET,
        { expiresIn: "1h" }
      );
      const refreshToken = jwt.sign(
        { id: user.id },
        process.env.JWT_REFRESH_SECRET,
        { expiresIn: "7d" }
      );
      const cookieOptions = {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "Lax",
        path: "/",
      };
      res.cookie("refreshToken", refreshToken, cookieOptions);
      res.cookie("accessToken", accessToken, cookieOptions);
      const membership = await StorageMember.findOne({
        where: { user_id: user.id },
        attributes: ["storage_id", "role"],
      });

      let storage = null;

      if (membership?.storage_id) {
        storage = await Storage.findByPk(membership.storage_id);
      }

      const userObj = user.toJSON();
      if (membership && membership.role) {
        userObj.role = membership.role; 
      }

      res.status(200).json({
        message: "Đăng nhập thành công",
        response: true,
        accessToken,
        refreshToken,
        user: userObj,
        ...(storage && { storage: storage.toJSON() }),
      });
    } catch (error) {
      console.error("Error:", error);
      res.status(500).json({ message: "Đã xảy ra lỗi: " + error.message });
    }
  }

  // Thêm hàm mới
  async googleLogin(req, res) {
    const { email, full_name } = req.body;
    try {
      let user = await User.findOne({ where: { email } });

      // Nếu người dùng chưa tồn tại, tạo mới
      if (!user) {
        // Tạo một mật khẩu ngẫu nhiên vì trường password_hash là bắt buộc
        const randomPassword = Math.random().toString(36).slice(-8);
        const hashedPassword = await bcrypt.hash(randomPassword, 10);

        user = await User.create({
          email,
          full_name,
          password_hash: hashedPassword,
          // google_id: google_id, // Nên thêm một cột google_id vào bảng users
          gender: 'Khác', // Mặc định
        });
      }

      // Tạo JWT tokens
      const accessToken = jwt.sign(
        { id: user.id, email: user.email },
        process.env.JWT_SECRET,
        { expiresIn: "1h" }
      );
      const refreshToken = jwt.sign(
        { id: user.id },
        process.env.JWT_REFRESH_SECRET,
        { expiresIn: "7d" }
      );

      // Tìm thông tin kho (nếu có)
      const membership = await StorageMember.findOne({
        where: { user_id: user.id },
        attributes: ["storage_id"],
      });

      let storage = null;
      if (membership?.storage_id) {
        storage = await Storage.findByPk(membership.storage_id);
      }

      res.status(200).json({
        message: "Đăng nhập thành công",
        response: true,
        accessToken,
        refreshToken,
        user,
        ...(storage && { storage: storage.toJSON() }),
      });
    } catch (error) {
      console.error("Google Login Error:", error);
      res.status(500).json({ message: "Lỗi đăng nhập bằng Google: " + error.message });
    }
  }

  async logout(req, res) {
    try {
      res.clearCookie("accessToken", { path: "/" });
      res.clearCookie("refreshToken", { path: "/" });
      res.status(200).json({ message: "Đăng xuất thành công", response: true });
    } catch (error) {
      console.error("Logout Error:", error);
      res.status(500).json({
        message: "Đã xảy ra lỗi khi đăng xuất: " + error.message,
        response: false,
      });
    }
  }

  async refreshToken(req, res) {
    try {
      const { refresh_token: refreshToken } = req.body;
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
          const newAccessToken = jwt.sign(
            { id: user.id, email: user.email },
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

  async update(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findByPk(id);
      if (!user) {
        return res.status(404).json({ error: "Người dùng không tồn tại" });
      }
      const { email, phone, full_name, password, avatar_url, gender } =
        req.body;
      const updateData = {
        email: email ?? user.email,
        phone: phone ?? user.phone,
        full_name: full_name ?? user.full_name,
        avatar_url: avatar_url ?? user.avatar_url,
        gender: gender ?? user.gender,
      };
      if (password) {
        updateData.password_hash = await bcrypt.hash(password, 10);
      }
      await user.update(updateData);
      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi cập nhật người dùng" });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      const user = await User.findByPk(id);
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
