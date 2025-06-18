const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Ingredient = sequelize.define(
  "ingredients",
  {
    id: {
      type: DataTypes.CHAR(36),
      primaryKey: true,
    },
    storage_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    category_id: {
      type: DataTypes.CHAR(36),
      allowNull: true,
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    unit: DataTypes.TEXT,
    import_date: DataTypes.DATEONLY,
    expire_date: DataTypes.DATEONLY,
    note: DataTypes.TEXT,
    status: {
      type: DataTypes.ENUM("con_dung", "het_han", "da_dung", "huy"),
      allowNull: false,
      defaultValue: "con_dung",
    },
    image_path: DataTypes.TEXT,
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    updated_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "ingredients",
    timestamps: false,
  }
);

module.exports = Ingredient;
