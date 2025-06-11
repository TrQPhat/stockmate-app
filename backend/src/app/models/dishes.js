const { DataTypes } = require("sequelize");
const sequelize = require("../../config/db");

const Dish = sequelize.define(
    "Dish",
    {
        id: {
            type: DataTypes.CHAR(36),
            primaryKey: true,
        },
        name: {
            type: DataTypes.STRING(255),
            allowNull: false,
        },
        description: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
        instructions: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        image_url: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
        cook_time_minutes: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        serving_size: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        created_by_user_id: {
            type: DataTypes.CHAR(36),
            allowNull: false,
        },
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
        tableName: "dishes",
        timestamps: false,
    }
);

module.exports = Dish;