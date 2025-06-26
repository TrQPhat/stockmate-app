const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Grocery = sequelize.define(
  "Grocery",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    storage_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    category_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    quantity: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
    },
    unit: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    import_date: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    expire_date: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    note: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    status: {
      type: DataTypes.ENUM("con_dung", "het_han", "da_dung", "huy"),
      defaultValue: "con_dung",
    },
    position_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    image_path: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    tableName: "groceries",
    timestamps: false,
  }
);

module.exports = Grocery;
