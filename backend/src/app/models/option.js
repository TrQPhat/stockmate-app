const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db"); // Đường dẫn đến file cấu hình Sequelize

const Option = sequelize.define(
  "Option",
  {
    option_id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    product_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
    description: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 0.0,
    },
  },
  {
    tableName: "option", // Tên bảng trong cơ sở dữ liệu
    timestamps: false, // Không sử dụng các cột createdAt và updatedAt
  }
);

module.exports = Option;
