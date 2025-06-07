const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const StorageMember = sequelize.define(
  "StorageMember",
  {
    id: {
      type: DataTypes.CHAR(36),
      primaryKey: true,
    },
    storage_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    user_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    role: {
      type: DataTypes.ENUM("owner", "editor", "viewer"),
      allowNull: false,
    },
    joined_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "storage_members",
    timestamps: false,
  }
);

module.exports = StorageMember;
