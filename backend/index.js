const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
require("dotenv").config();
const app = express();
const path = require("path");
const port = process.env.PORT;

// Sử dụng bodyParser
const bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: true }));
const cookieParser = require("cookie-parser");
app.use(cookieParser());
// Cấu hình CORS
// app.use(cors({
//   origin: 'http://localhost:3001', // Chỉ cho phép frontend Next.js truy cập
//   methods: 'GET,POST,PUT,DELETE',
//   allowedHeaders: 'Content-Type,Authorization'
// }));

app.use(
  cors({
    origin: "http://localhost:3001", // ⚡️ Đảm bảo đúng frontend
    credentials: true, // ✅ Cho phép gửi & nhận cookie
    methods: "GET,POST,PUT,DELETE",
    allowedHeaders: "Content-Type,Authorization",
  })
);

const { sequelize } = require("../server/src/app/models/index");

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan("combined"));

const router = require("../server/src/router");
app.use("/api", router);
app.use("/uploads", express.static(path.join(__dirname, "/src/uploads")));

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
