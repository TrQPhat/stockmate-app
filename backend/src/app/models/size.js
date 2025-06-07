const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db"); // Đường dẫn đến file cấu hình Sequelize

const Size = sequelize.define(
  "Size",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    tag: {
      type: DataTypes.STRING(10),
      allowNull: false,
      unique: true,
    },
    description: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
  },
  {
    tableName: "size", // Tên bảng trong cơ sở dữ liệu
    timestamps: false, // Không sử dụng các cột createdAt và updatedAt
  }
);

module.exports = Size;
