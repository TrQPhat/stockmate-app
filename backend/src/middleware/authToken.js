const jwt = require("jsonwebtoken");

const verifyToken = (req, res, next) => {
  console.log(">> Bắt đầu kiểm tra token...");

  let token = req.headers.authorization?.split(" ")[1];
  console.log(">> Token từ header:", token);

  if (!token) {
    token = req.cookies?.accessToken;
    console.log(">> Token từ cookies:", token);
  }

  if (!token) {
    console.warn(">> ❌ Không tìm thấy token ở header hoặc cookie");
    return res
      .status(403)
      .json({ message: "Không có token, truy cập bị từ chối" });
  }

  console.log(">> Tiến hành xác thực token...");
  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      console.error(">> ❌ Token không hợp lệ hoặc hết hạn:", err.message);
      return res
        .status(401)
        .json({ message: "Token không hợp lệ hoặc đã hết hạn" });
    }

    console.log(">> ✅ Token hợp lệ. Payload:", decoded);
    req.user = decoded;
    next();
  });
};

module.exports = verifyToken;
