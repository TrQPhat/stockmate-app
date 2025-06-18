const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Ingredientlog = sequelize.define(
  "ingredient_logs",
  {
    id: {
      type: DataTypes.CHAR(36),
      primaryKey: true,
    },
    product_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    action: {
      type: DataTypes.ENUM("da_dung", "huy", "cap_nhat", "tu_dong_het_han"),
      allowNull: false,
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    note: DataTypes.TEXT,
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "ingredient_logs",
    timestamps: false,
  }
);

module.exports = Ingredientlog;
