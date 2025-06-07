const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Category = sequelize.define(
  "Category",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    icon_code_point: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    icon_font_family: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    icon_font_package: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    tableName: "categories",
    timestamps: false,
  }
);

module.exports = Category;
