const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Reminder = sequelize.define(
  "Reminder",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    remind_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    is_done: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "reminders",
    timestamps: false,
  }
);

module.exports = Reminder;
