const sequelize = require("../../config/db");

// Import các model
const User = require("./users");
const FcmToken = require("./fcm_tokens");
const Storage = require("./storages");
const StorageMember = require("./storage_members");
const Product = require("./products");
const ProductLog = require("./product_log");

const Category = require("./categories");
const ShoppingList = require("./shopping_lists");
const ShoppingListItem = require("./shopping_list_items");
const Dish = require("./dishes");
const DishIngredient = require("./dish_ingredients");
const CookingHistory = require("./cooking_history");
const Position = require("./position");

// --- Associations ---

User.hasMany(FcmToken, { foreignKey: "user_id", sourceKey: "user_id" });
FcmToken.belongsTo(User, { foreignKey: "user_id", targetKey: "user_id" });

User.hasMany(Storage, { foreignKey: "owner_id", sourceKey: "user_id" });
Storage.belongsTo(User, { foreignKey: "owner_id", targetKey: "user_id" });

Storage.hasMany(StorageMember, { foreignKey: "storage_id" });
StorageMember.belongsTo(Storage, { foreignKey: "storage_id" });

User.hasMany(StorageMember, { foreignKey: "user_id", sourceKey: "user_id" });
StorageMember.belongsTo(User, { foreignKey: "user_id", targetKey: "user_id" });

Storage.hasMany(Product, { foreignKey: "storage_id" });
Product.belongsTo(Storage, { foreignKey: "storage_id" });

Product.hasMany(ProductLog, { foreignKey: "product_id" });
ProductLog.belongsTo(Product, { foreignKey: "product_id" });

Category.hasMany(Product, { foreignKey: "category_id" });
Product.belongsTo(Category, { foreignKey: "category_id" });

User.hasMany(ShoppingList, { foreignKey: "user_id", sourceKey: "user_id" });
ShoppingList.belongsTo(User, { foreignKey: "user_id", targetKey: "user_id" });

ShoppingList.hasMany(ShoppingListItem, {
  foreignKey: "shopping_list_id",
  onDelete: "CASCADE",
});
ShoppingListItem.belongsTo(ShoppingList, { foreignKey: "shopping_list_id" });

Product.hasMany(ShoppingListItem, { foreignKey: "product_id" });
ShoppingListItem.belongsTo(Product, { foreignKey: "product_id" });

User.hasMany(Dish, { foreignKey: "created_by_user_id", sourceKey: "user_id" });
Dish.belongsTo(User, {
  foreignKey: "created_by_user_id",
  targetKey: "user_id",
});

Dish.hasMany(DishIngredient, { foreignKey: "dish_id", onDelete: "CASCADE" });
DishIngredient.belongsTo(Dish, { foreignKey: "dish_id" });

Product.hasMany(DishIngredient, { foreignKey: "product_id" });
DishIngredient.belongsTo(Product, { foreignKey: "product_id" });

User.hasMany(CookingHistory, { foreignKey: "user_id", sourceKey: "user_id" });
CookingHistory.belongsTo(User, { foreignKey: "user_id", targetKey: "user_id" });

Dish.hasMany(CookingHistory, { foreignKey: "dish_id" });
CookingHistory.belongsTo(Dish, { foreignKey: "dish_id" });
Product.belongsTo(Position, { foreignKey: "position_id" });
Position.hasMany(Product, { foreignKey: "position_id" });

// Export các model cùng sequelize instance
module.exports = {
  sequelize,
  User,
  FcmToken,
  Storage,
  StorageMember,
  Product,
  ProductLog,
  Category,
  ShoppingList,
  ShoppingListItem,
  Dish,
  DishIngredient,
  CookingHistory,
  Position,
};
