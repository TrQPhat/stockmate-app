const { DataTypes } = require("sequelize");
const sequelize = require("../config/db");

const Storage = sequelize.define(
  "Storage",
  {
    id: {
      type: DataTypes.CHAR(36),
      primaryKey: true,
    },
    name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    owner_id: {
      type: DataTypes.CHAR(36),
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
  }
);

module.exports = Storage;
