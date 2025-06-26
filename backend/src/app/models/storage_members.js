const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const StorageMember = sequelize.define(
  "StorageMember",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    storage_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    role: {
      type: DataTypes.ENUM("owner", "member"),
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
    underscored: true,
  }
);

module.exports = StorageMember;
