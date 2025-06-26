const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const ShoppingList = sequelize.define(
  "ShoppingList",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    storage_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    purpose: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    purchase_date: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: () => {
        const now = new Date();
        now.setDate(now.getDate() + 1); // Cộng thêm 1 ngày
        return now;
      },
    },
  },
  {
    tableName: "shopping_lists",
    timestamps: false,
  }
);

module.exports = ShoppingList;
