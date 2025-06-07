const { DataTypes } = require('sequelize');
const sequelize = require('../../config/db');

const Ingredient = sequelize.define('Ingredient', {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  name: { type: DataTypes.STRING, allowNull: false },
  product_id: { type: DataTypes.INTEGER, allowNull: true },
  quantity: { type: DataTypes.STRING, allowNull: true }
}, {
  tableName: 'ingredients',
  timestamps: false
});

module.exports = Ingredient;