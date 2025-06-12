const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const DishIngredient = sequelize.define(
  "DishIngredient",
  {
    id: {
      type: DataTypes.CHAR(36),
      primaryKey: true,
    },
    dish_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    product_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    quantity: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    unit: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
  },
  {
    tableName: "dish_ingredients",
    timestamps: false, // Bảng này không có created_at/updated_at
  }
);

module.exports = DishIngredient;