const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const FcmToken = sequelize.define(
  "FcmToken",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    token: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    device_name: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    platform: {
      type: DataTypes.ENUM("android", "ios", "web"),
      allowNull: true,
    },
    updated_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "fcm_tokens",
    timestamps: false,
  }
);

module.exports = FcmToken;
