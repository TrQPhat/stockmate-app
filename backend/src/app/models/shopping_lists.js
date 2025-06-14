const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const ShoppingList = sequelize.define(
  "ShoppingList",
  {
    id: {
      type: DataTypes.CHAR(36),
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    purchase_date: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    total_cost: {
      type: DataTypes.DECIMAL(15, 2),
      defaultValue: 0.00,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    updated_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    }
  },
  {
    tableName: "shopping_lists",
    timestamps: false,
  }
);

module.exports = ShoppingList;