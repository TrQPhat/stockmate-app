const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const ShoppingListItem = sequelize.define(
  "ShoppingListItem",
  {
    id: {
      type: DataTypes.CHAR(36),
      primaryKey: true,
    },
    shopping_list_id: {
      type: DataTypes.CHAR(36),
      allowNull: false,
    },
    product_id: {
      type: DataTypes.CHAR(36),
      allowNull: true,
    },
    item_name: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    quantity: {
      type: DataTypes.INTEGER,
      defaultValue: 1,
    },
    unit: {
      type: DataTypes.TEXT,
      allowNull: true,
    },

    price: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.00,
    },
    is_purchased: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    }
  },
  {
    tableName: "shopping_list_items",
    timestamps: false,
  }
);

module.exports = ShoppingListItem;