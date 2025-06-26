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
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: null,
    },
  },
  {
    tableName: "categories",
    timestamps: false,
  }
);

module.exports = Category;
