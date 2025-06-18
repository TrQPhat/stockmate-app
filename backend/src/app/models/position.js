const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Position = sequelize.define(
  "positions",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    timestamps: false, // nếu không cần createdAt, updatedAt
    tableName: "positions",
  }
);

module.exports = Position;
