const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Dish = sequelize.define(
  "Dish",
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
    instructions: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    image_url: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    cook_time_minutes: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    storage_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    tableName: "dishes",
    timestamps: false,
  }
);

module.exports = Dish;
