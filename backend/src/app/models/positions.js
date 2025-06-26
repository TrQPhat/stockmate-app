const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Position = sequelize.define(
  "Position",
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
    tableName: "positions",
    timestamps: false,
    underscored: true,
  }
);

module.exports = Position;
