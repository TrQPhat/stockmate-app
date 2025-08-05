const sequelize = require("../../config/db");

// Import models
const User = require("./users");
const FcmToken = require("./fcm_tokens");
const Storage = require("./storages");
const StorageMember = require("./storage_members");
const Grocery = require("./groceries");
const Ingredient = require("./ingredients");
const Category = require("./categories");
const Position = require("./positions");
const Dish = require("./dishes");
const Note = require("./notes");
const Favorite = require("./favorites");
const Reminder = require("./reminders");
const ShoppingList = require("./shopping_lists");
const ShoppingItem = require("./shopping_items");
const Notification = require("./notifications");

// --- Associations ---

// User
User.hasMany(FcmToken, { foreignKey: "user_id" });
FcmToken.belongsTo(User, { foreignKey: "user_id" });

User.hasMany(Storage, { foreignKey: "owner_id" });
Storage.belongsTo(User, { foreignKey: "owner_id" });

User.hasMany(StorageMember, { foreignKey: "user_id" });
StorageMember.belongsTo(User, { foreignKey: "user_id" });

User.hasMany(Favorite, { foreignKey: "user_id" });
Favorite.belongsTo(User, { foreignKey: "user_id" });

User.hasMany(Note, { foreignKey: "user_id" });
Note.belongsTo(User, { foreignKey: "user_id", as: "user" });

User.hasMany(Reminder, { foreignKey: "user_id" });
Reminder.belongsTo(User, { foreignKey: "user_id" });

// Storage
Storage.hasMany(StorageMember, { foreignKey: "storage_id" });
StorageMember.belongsTo(Storage, { foreignKey: "storage_id" });

Storage.hasMany(Grocery, { foreignKey: "storage_id" });
Grocery.belongsTo(Storage, { foreignKey: "storage_id" });

Storage.hasMany(Dish, { foreignKey: "storage_id" });
Dish.belongsTo(Storage, { foreignKey: "storage_id" });

Storage.hasMany(ShoppingList, { foreignKey: "storage_id" });
ShoppingList.belongsTo(Storage, { foreignKey: "storage_id" });

// Grocery
Grocery.hasMany(Ingredient, { foreignKey: "grocery_id" });
Ingredient.belongsTo(Grocery, { foreignKey: "grocery_id" });

Grocery.belongsTo(Category, { foreignKey: "category_id" });
Category.hasMany(Grocery, { foreignKey: "category_id" });

Grocery.belongsTo(Position, { foreignKey: "position_id" });
Position.hasMany(Grocery, { foreignKey: "position_id" });

// Dish
Dish.hasMany(Note, { foreignKey: "dish_id" });
Note.belongsTo(Dish, { foreignKey: "dish_id" });

Dish.hasMany(Favorite, { foreignKey: "dish_id" });
Favorite.belongsTo(Dish, { foreignKey: "dish_id" });

// Shopping List
ShoppingList.hasMany(ShoppingItem, { foreignKey: "list_id", as: "items" });
ShoppingItem.belongsTo(ShoppingList, { foreignKey: "list_id" });

// --- Export all models and sequelize instance ---
module.exports = {
  sequelize,
  User,
  FcmToken,
  Storage,
  StorageMember,
  Grocery,
  Ingredient,
  Category,
  Position,
  Dish,
  Note,
  Favorite,
  Reminder,
  ShoppingList,
  ShoppingItem,
  Notification,
};
