const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const FcmToken = sequelize.define(
  "FcmToken",
  {
    id: {
      type: DataTypes.CHAR(36),
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    token: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    device_name: DataTypes.TEXT,
    platform: DataTypes.ENUM("android", "ios", "web"),
    created_at: {
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
