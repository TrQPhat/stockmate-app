const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Storage = sequelize.define(
  "Storage",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true, // ✅ ID tự tăng
    },
    name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    owner_id: {
      type: DataTypes.INTEGER, // ✅ đổi từ CHAR(36) sang INTEGER
      allowNull: false,
    },
    key: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "storages",
    timestamps: false,
    underscored: true,
  }
);

module.exports = Storage;
