const sequelize = require("../../config/db");

// Import các model
const User = require("./users");
const FcmToken = require("./fcm_tokens");
const Storage = require("./storages");
const StorageMember = require("./storage_members");
const Product = require("./products");
const ProductLog = require("./product_logs");

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

// Export các model cùng sequelize instance
module.exports = {
  sequelize,
  User,
  FcmToken,
  Storage,
  StorageMember,
  Product,
  ProductLog,
};
