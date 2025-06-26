const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Ingredient = sequelize.define(
  "Ingredient",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    grocery_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    preparetion: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    quantity: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
  },
  {
    tableName: "ingredients",
    timestamps: false,
  }
);

module.exports = Ingredient;
