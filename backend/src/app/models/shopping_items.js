// models/ShoppingItem.js
const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const ShoppingItem = sequelize.define(
  "ShoppingItem",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    list_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    item_name: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 1,
    },
    unit: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    expire: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    is_purchased: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    category_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    tableName: "shopping_items",
    timestamps: false,
  }
);

module.exports = ShoppingItem;
