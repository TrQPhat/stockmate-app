const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const CookingHistory = sequelize.define(
  "CookingHistory",
  {
    id: {
      type: DataTypes.CHAR(36),
      primaryKey: true,
    },
    dish_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    user_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    cooked_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    tableName: "cooking_history",
    timestamps: false, // Bảng này đã có cột 'cooked_at' nên không cần timestamps tự động
  }
);

module.exports = CookingHistory;