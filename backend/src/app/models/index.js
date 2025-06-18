const sequelize = require("../../config/db");

// Import các model
const User = require("./users");
const FcmToken = require("./fcm_tokens");
const Storage = require("./storages");
const StorageMember = require("./storage_members");
const Ingredient = require("./ingredients");
const Ingredientlog = require("./ingredient_log");

const Category = require("./categories");
const ShoppingList = require("./shopping_lists");
const ShoppingListItem = require("./shopping_list_items");
const Recipe = require("./recipe");
const Recipe_ingredient = require("./recipe_ingredients");

// --- Associations ---

User.hasMany(FcmToken, { foreignKey: "user_id", sourceKey: "user_id" });
FcmToken.belongsTo(User, { foreignKey: "user_id", targetKey: "user_id" });

User.hasMany(Storage, { foreignKey: "owner_id", sourceKey: "user_id" });
Storage.belongsTo(User, { foreignKey: "owner_id", targetKey: "user_id" });

Storage.hasMany(StorageMember, { foreignKey: "storage_id" });
StorageMember.belongsTo(Storage, { foreignKey: "storage_id" });

User.hasMany(StorageMember, { foreignKey: "user_id", sourceKey: "user_id" });
StorageMember.belongsTo(User, { foreignKey: "user_id", targetKey: "user_id" });

Storage.hasMany(Ingredient, { foreignKey: "storage_id" });
Ingredient.belongsTo(Storage, { foreignKey: "storage_id" });

Ingredient.hasMany(Ingredientlog, { foreignKey: "product_id" });
Ingredientlog.belongsTo(Ingredient, { foreignKey: "product_id" });

Category.hasMany(Ingredient, { foreignKey: "category_id" });
Ingredient.belongsTo(Category, { foreignKey: "category_id" });

User.hasMany(ShoppingList, { foreignKey: "user_id", sourceKey: "user_id" });
ShoppingList.belongsTo(User, { foreignKey: "user_id", targetKey: "user_id" });

ShoppingList.hasMany(ShoppingListItem, {
  foreignKey: "shopping_list_id",
  onDelete: "CASCADE",
});
ShoppingListItem.belongsTo(ShoppingList, { foreignKey: "shopping_list_id" });

Ingredient.hasMany(ShoppingListItem, { foreignKey: "product_id" });
ShoppingListItem.belongsTo(Ingredient, { foreignKey: "product_id" });

User.hasMany(Recipe, { foreignKey: "created_by_user_id", sourceKey: "user_id" });
Recipe.belongsTo(User, {
  foreignKey: "created_by_user_id",
  targetKey: "user_id",
});

Recipe.hasMany(Recipe_ingredient, { foreignKey: "dish_id", onDelete: "CASCADE" });
Recipe_ingredient.belongsTo(Recipe, { foreignKey: "dish_id" });

Ingredient.hasMany(Recipe_ingredient, { foreignKey: "product_id" });
Recipe_ingredient.belongsTo(Ingredient, { foreignKey: "product_id" });

// Export các model cùng sequelize instance
module.exports = {
  sequelize,
  User,
  FcmToken,
  Storage,
  StorageMember,
  Ingredient,
  Ingredientlog,
  Category,
  ShoppingList,
  ShoppingListItem,
  Recipe,
  Recipe_ingredient,
};
